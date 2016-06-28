//
//  QAViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/24/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LoadMoreTableFooterViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let ReuseID_QACell = "QAPostCell"
    let QADetailSegueID = "QADetailSegue"
    
    var tableRefresher:UIRefreshControl!
    var QACellMaxY:CGFloat = 0
    var cameBackFromIndexPath:NSIndexPath!
    
    var posts:[QAPost] = []
    
    var textFieldNeedsAdjust = false
    var queryCompletionCounter:Int = 0
    var allowLoadingMore = true
    
    let SINGLE_LOAD_AMOUNT:Int = 8
    var skipAmount:Int = 0
    var loadMoreFooterView: LoadMoreTableFooterView!
    var isLoadingMore: Bool = false
    var couldLoadMore: Bool = false
    
    var queryPredicate: NSPredicate!
    var ascendingOrder = PFKey.CREATED_AT
    var descendingOrder = "\(PFKey.QA.VOTE),\(PFKey.CREATED_AT)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryPredicate = NSPredicate(format: "type = %@", PFKey.QA.TYPE.QUESTION)
        
        initUI();
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        let nib = UINib(nibName: "QAPostCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_QACell)
        
        tableRefresher = UIRefreshControl()
        //tableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        tableRefresher.addTarget(self, action: #selector(QAViewController.QARefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
        
        loadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, tableView.contentSize.height, tableView.frame.size.width, tableView.frame.size.height))
        loadMoreFooterView.delegate = self
        loadMoreFooterView.backgroundColor = UIColor.clearColor()
        tableView.addSubview(loadMoreFooterView)
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
                posts.removeAll(keepCapacity: true)
                skipAmount = 0
            }
            couldLoadMore = result.count >= SINGLE_LOAD_AMOUNT
            skipAmount += result.count
            print("Find \(result.count) results.")
            for re in result {
                if let newPost = QAPost(parseObject: re) {
                    posts.append(newPost)
                }
            }
            posts.sortInPlace({AppTools.compareQAPostIsOrderedBefore(p1: $0, p2: $1)})
            //beginFilter()
            tableView.reloadData()
        }
        else {
            print("query error: (error)")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_QACell, forIndexPath: indexPath) as! QAPostCell
        cell.initWithPost(posts[indexPath.row], fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! QAPostCell
        AppData.QAData.selectedQAQuestion = cell.childQA
        cameBackFromIndexPath = indexPath
        self.performSegueWithIdentifier(QADetailSegueID, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
