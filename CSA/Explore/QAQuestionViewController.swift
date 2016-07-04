//
//  QADetailViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/25/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoadMoreTableFooterViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let ReuseID_QACell = "QAPostCell"
    let ReuseID_NoAnswer = "NoAnswerCell"
    let ReuseID_ComposeAnswer = "ComposeAnswerCell"
    let ReuseID_EditAnswerSegue = "QAEditAnswerSegue"
    let ReuseID_AnswerSegue = "QAAnswerSegue"
    let ReuseID_EditQuestionSegue = "QAEditQuestionSegue"
    
    var tableRefresher: UIRefreshControl!
    var QACellMaxY: CGFloat = 0
    var cameBackFromIndexPath: NSIndexPath!
    
    var question: QAPost!
    var posts:[QAPost] = [] // for tableview
    var answers: [PFObject] = []
    var noAnswer: Bool = true
    
    var textFieldNeedsAdjust = false
    var queryCompletionCounter:Int = 0
    var allowLoadingMore = true
    
    let SINGLE_LOAD_AMOUNT: Int = 8
    var skipAmount: Int = 0
    var loadMoreFooterView: LoadMoreTableFooterView!
    var isLoadingMore: Bool = false
    var couldLoadMore: Bool = false
    
    var didAnswer = false
    var myAnswer: QAPost?
    
    var queryPredicate: NSPredicate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        question = AppData.QAData.selectedQAQuestion
        posts.append(question)
        answers = question.answers
        
        queryPredicate = NSPredicate(format: "question = %@", self.question.PFInstance)
        
        initUI();
    }
    
    func initUI() {
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        var nib = UINib(nibName: "QAPostCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_QACell)
        nib = UINib(nibName: "NoAnswerCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_NoAnswer)
        nib = UINib(nibName: "ComposeAnswerCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_ComposeAnswer)
        
        tableRefresher = UIRefreshControl()
        //tableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        tableRefresher.addTarget(self, action: #selector(QAViewController.QARefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
        
        loadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, tableView.contentSize.height, tableView.frame.size.width, tableView.frame.size.height))
        loadMoreFooterView.delegate = self
        loadMoreFooterView.backgroundColor = UIColor.clearColor()
        tableView.addSubview(loadMoreFooterView)
        
        if question.author.objectId! != PFUser.currentUser()!.objectId! {
            editButton.enabled = false
            editButton.tintColor = UIColor.clearColor()
        }
        else {
            editButton.enabled = true
            editButton.tintColor = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AppData.QAData.wipeSelectedRsData()
        tableRefresher.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        QATableAutoRefresh()
        if let i = cameBackFromIndexPath {
            tableView.reloadRowsAtIndexPaths([i], withRowAnimation: UITableViewRowAnimation.None)
            cameBackFromIndexPath = nil
        }
    }
    
    // MARK: - Data Query
    func QATableAutoRefresh(){
        tableRefresher.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.tableRefresher.frame.height
                }, completion: nil)
        }
        QARefreshSelector()
    }
    
    func QARefreshSelector() {
        print("QA Begin Refreshing")
        AppStatus.QAStatus.tableShouldRefresh = false
        allowLoadingMore = false
        let query = PFQuery(className: PFKey.QA.CLASSKEY, predicate: queryPredicate)
        query.orderByDescending(PFKey.QA.VOTE)
        query.includeKey(PFKey.QA.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.limit = SINGLE_LOAD_AMOUNT
        queryCompletionCounter = 2
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error, removeAll: true)
            self.queryCompletionUIHandler(error: error)
            self.allowLoadingMore = true
        }
    }
    
    func QARefreshSelectorCacheFirst() {
        print("QA Begin Refreshing With Cache")
        AppStatus.QAStatus.tableShouldRefresh = false
        allowLoadingMore = false
        let query = PFQuery(className: PFKey.QA.CLASSKEY, predicate: queryPredicate)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.QA.AUTHOR)
        query.limit = SINGLE_LOAD_AMOUNT
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter += 1
            self.queryCompletionDataHandler(result: result,error: error, removeAll: true)
            self.queryCompletionUIHandler(error: error)
            if self.queryCompletionCounter >= 2 {
                self.allowLoadingMore = true
            }
        }
    }
    
    func QALoadMoreSelector() {
        print("QA Begin Loading More")
        let query = PFQuery(className: PFKey.QA.CLASSKEY, predicate: queryPredicate)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.QA.AUTHOR)
        query.limit = SINGLE_LOAD_AMOUNT
        query.skip = skipAmount
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error, removeAll: false)
            self.doneLoadingMoreTableViewData()
        }
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {
            /*
             self.view.makeToast(message: "Fetching QA", duration: 1.0, position: HRToastPositionCenterAbove)*/
            return
        }
        if self.queryCompletionCounter >= 2 {
            tableRefresher.endRefreshing()
            if error == nil{
                /*
                 self.view.makeToast(message: "Refresh succeeded", duration: 0.5, position: HRToastPositionCenterAbove)*/
                AppStatus.QAStatus.lastRefreshTime = NSDate()
            }else{
                self.view.makeToast(message: "Refresh failed. Please try again later.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result:[PFObject]!, error:NSError!, removeAll:Bool) {
        print("QA query completed for the \(self.queryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            if removeAll {
                // save the first one because it's the question
                var i = posts.count - 1
                while (i > 0) {
                    posts.removeAtIndex(i)
                    i -= 1
                }
                skipAmount = 0
            }
            couldLoadMore = result.count >= SINGLE_LOAD_AMOUNT
            skipAmount += result.count
            print("Find \(result.count) results.")
            for re in result {
                if let newPost = QAPost(parseObject: re) {
                    noAnswer = false
                    posts.append(newPost)
                    if (newPost.author.objectId == PFUser.currentUser()!.objectId) {
                        didAnswer = true
                        myAnswer = newPost
                    }
                }
            }
            sortPosts()
            //beginFilter()
            tableView.reloadData()
        }
        else {
            print("query error: (error)")
        }
    }
    
    // only sort the answers
    func sortPosts() {
        posts.removeAtIndex(0)
        posts.sortInPlace({AppTools.compareQAPostIsOrderedBefore(p1: $0, p2: $1)})
        posts.insert(question, atIndex: 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // no answer: question + edit answer + no answer cell
        // yes answer: question + edit answer + answers
        return noAnswer ? 3 : posts.count + 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // row #1 is the edit answer cell, other answers have an offset index of 1 because of this
        if (indexPath.row == 1) {
            let editCell = tableView.dequeueReusableCellWithIdentifier(ReuseID_ComposeAnswer, forIndexPath: indexPath)
            return editCell
        }
        // display "no answer yet" when there is no answer
        if (indexPath.row == 2 && noAnswer) {
            let noCell = tableView.dequeueReusableCellWithIdentifier(ReuseID_NoAnswer, forIndexPath: indexPath)
            noCell.selectionStyle = .None
            return noCell
        }
        let postIndex = indexPath.row > 0 ? indexPath.row - 1 : 0
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_QACell, forIndexPath: indexPath) as! QAPostCell
        cell.initWithPost(posts[postIndex], fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
        
        // the question cannot be clicked anymore
        if (indexPath.row == 0) {
            cell.accessoryType = .None
            cell.selectionStyle = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row > 1) {
            return 150
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // selection on an answer
        if !noAnswer && indexPath.row > 1 {
            selectAnswer(indexPath.row - 1) //offset of 1 since 0 is for the question
        }
        // selection on compose answer cell
        else if indexPath.row == 1 {
            composeAnswer()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: selection on rows of tableview
    func selectAnswer(postIndex: Int) {
        AppData.QAData.selectedQAAnswer = self.posts[postIndex]
        self.performSegueWithIdentifier(ReuseID_AnswerSegue, sender: self)
    }
    
    // if the user already answered, pull up the answer
    // if not, compose new answer
    func composeAnswer() {
        AppData.QAData.selectedQAQuestion = self.question
        AppData.QAData.myAnswer = self.myAnswer
        self.performSegueWithIdentifier(ReuseID_EditAnswerSegue, sender: self)
    }
    
    //// MARK: - Pull to load more
    // LoadMoreTableFooterViewDelegate
    func loadMoreTableFooterDidTriggerRefresh(view: LoadMoreTableFooterView) {
        loadMoreTableViewDataSource()
    }
    
    func loadMoreTableFooterDataSourceIsLoading(view: LoadMoreTableFooterView) -> Bool {
        return isLoadingMore
    }
    
    func loadMoreTableViewDataSource() {
        if isLoadingMore {return}
        isLoadingMore = true
        QALoadMoreSelector()
    }
    
    func doneLoadingMoreTableViewData() {
        isLoadingMore = false
        loadMoreFooterView.loadMoreScrollViewDataSourceDidFinishedLoading()
    }
    
    // UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if (allowLoadingMore && couldLoadMore) {
            loadMoreFooterView.loadMoreScrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (allowLoadingMore && couldLoadMore) {
            loadMoreFooterView.loadMoreScrollViewDidEndDragging(scrollView)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == ReuseID_EditQuestionSegue) {
            AppData.QAData.myQuestion = question
        }
    }
}
