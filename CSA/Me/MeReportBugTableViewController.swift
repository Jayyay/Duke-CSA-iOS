//
//  MeReportBugTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class MeReportBugTableViewController: UITableViewController {

    @IBOutlet weak var txtviewPost: UITextView!
    @IBOutlet weak var btnPost: UIButton!
    
    
    let ReuseID_MainCell = "IDBasicPostCell"
    let timeoutInSec:NSTimeInterval = 5.0
    
    var postConnectSuccess = false
    var postAllowed = true
    
    var queryCompletionCounter = 0
    
    var postArr:[BasicPost] = []
        
    // MARK: - IBAction
    @IBAction func onPost(sender: PFObject) {
        if !postAllowed{
            return
        }
        txtviewPost.resignFirstResponder()
        
        //check string
        if !AppTools.stringIsValid(txtviewPost.text){return}
        
        //create new parse object
        let newBug = PFObject(className: PFKey.ME.BUG_REPORT.CLASSKEY)
        newBug[PFKey.IS_VALID] = true
        newBug[PFKey.EVENT.DIS.AUTHOR] = PFUser.currentUser()
        newBug[PFKey.EVENT.DIS.MAIN_POST] = txtviewPost.text
        
        //change app status
        postConnectSuccess = false
        postAllowed = true
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(timeoutInSec, target: self, selector: Selector("postTimeOut"), userInfo: nil, repeats: false)
        newBug.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            
            //case handle
            if success{
                self.txtviewPost.text = ""
                self.view.makeToast(message: "Succeeded", duration: 0.5, position: HRToastPositionCenterAbove)
                self.refreshSelectorCacheFirst()
            }else{
                self.view.makeToast(message: "Eh..Failed to post. Please try again later :(", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func postTimeOut() {
        if !postConnectSuccess{
            print("Post time out")
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: "Connecting time out, job sended into background. Please wait.", duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }
    
    
    // MARK: - Init
    func initUI() {
        txtviewPost.layer.borderColor = UIColor.blackColor().CGColor
        txtviewPost.layer.borderWidth = 0.5
        txtviewPost.layer.cornerRadius = 2
        txtviewPost.layer.masksToBounds = true
        txtviewPost.scrollRangeToVisible(NSMakeRange(0, 0))
        
        btnPost.layer.cornerRadius = 5.0
        btnPost.layer.masksToBounds = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let nib = UINib(nibName: "BasicPostCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_MainCell)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: Selector("refreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        tableAutoRefresh()
    }
    
    //MARK: - Data Query
    func tableAutoRefresh(){
        self.refreshControl!.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.refreshControl!.frame.height
                }, completion: nil)
        }
        refreshSelectorCacheFirst()
    }
    
    func refreshSelectorCacheFirst() {
        print("Bug Report Begin Refreshing Cache First")
        let query = PFQuery(className: PFKey.ME.BUG_REPORT.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.ME.BUG_REPORT.AUTHOR)
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter++
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        }
    }
    
    func refreshSelector() {
        print("Bug Report Begin Refreshing")
        let query = PFQuery(className: PFKey.ME.BUG_REPORT.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.ME.BUG_REPORT.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        self.queryCompletionCounter = 2
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter++
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        }
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {
            return
        }
        if self.queryCompletionCounter >= 2 {
            self.refreshControl!.endRefreshing()
            if error != nil{
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result:[PFObject]!, error:NSError!) {
        print("Bug query completed for the \(queryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) results.")
            if let arr = result {
                postArr.removeAll(keepCapacity: true)
                for b in arr {
                    if let newPost = BasicPost(parseObject: b) {
                        postArr.append(newPost)
                    }
                }
            }
            tableView.reloadData()
        }else{
            print("query error: \(error)", terminator: "")
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_MainCell, forIndexPath: indexPath) as! BasicPostCell
        cell.initWithPost(postArr[indexPath.row], parentVC: self, fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
}
