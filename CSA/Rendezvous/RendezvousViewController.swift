//
//  RendezvousViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/23/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class RendezvousViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ENSideMenuDelegate, LoadMoreTableFooterViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnHeader1: UIButton!
    @IBOutlet weak var btnHeader2: UIButton!
    @IBOutlet weak var btnHeader3: UIButton!
    @IBOutlet weak var btnHeader4: UIButton!
    @IBOutlet weak var btnHeader5: UIButton!
    @IBOutlet weak var btnHeader6: UIButton!
    var headerArr:[UIButton]!
    
    let SegueID_Post = "rsPostSegue"
    let SegueID_RsDetail = "rsDetailSegue"
    let ReuseID_RsCell = "IDRsMainPostCell"
    //let timeoutInSec:NSTimeInterval = 5.0
    
    var tableRefresher:UIRefreshControl!
    var rsCellMaxY:CGFloat = 0
    var cameBackFromIndexPath:NSIndexPath!
    
    var rdzvs:[Rendezvous] = []
    
    var textFieldNeedsAdjust = false
    var queryCompletionCounter:Int = 0
    var allowLoadingMore = true
    
    var previousFilterIndex = 0
    var currentFilterMode:String = RsTag.all
    var filteredRs:[Rendezvous] = []
    
    let SINGLE_LOAD_AMOUNT:Int = 8
    var skipAmount:Int = 0
    var loadMoreFooterView: LoadMoreTableFooterView!
    var isLoadingMore: Bool = false
    var couldLoadMore: Bool = false
    
    @IBAction func onClickPost(sender: AnyObject) {
        if let postVC = AppData.RendezvousData.postVC  {
            self.navigationController?.pushViewController(postVC, animated: true)
        }else{
            self.performSegueWithIdentifier(SegueID_Post, sender: self)
        }
    }
    
    @IBAction func onFilter(sender: AnyObject) {
        let index = sender.tag!
        if index == previousFilterIndex {
            return
        }
        
        
        headerArr[previousFilterIndex].layer.cornerRadius = headerArr[previousFilterIndex].frame.height * 0.5
        headerArr[index].layer.cornerRadius = headerArr[index].frame.height * 0.1
        if index == 0 {
            currentFilterMode = RsTag.all
        }else{
            currentFilterMode = RsTag.tagIndexToName[index - 1]
        }
        
        previousFilterIndex = index
        beginFilter()
        tableView.reloadData()
    }
    
    func beginFilter(){
        if currentFilterMode == RsTag.all {
            filteredRs = rdzvs
            return
        }
        filteredRs = rdzvs.filter({$0.tags.contains(self.currentFilterMode)})
    }
    
    func initUI() {
        headerArr = [btnHeader1, btnHeader2, btnHeader3, btnHeader4, btnHeader5, btnHeader6]
        for button in headerArr {
            button.layer.cornerRadius = button.frame.height * 0.5
            button.layer.masksToBounds = true
        }
        btnHeader1.layer.cornerRadius = btnHeader1.frame.height * 0.1
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        tableView.delegate = self
        
        let nib = UINib(nibName: "RendezvousCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_RsCell)
        
        tableRefresher = UIRefreshControl()
        //tableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        tableRefresher.addTarget(self, action: Selector("rsRefreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
        
        loadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, tableView.contentSize.height, tableView.frame.size.width, tableView.frame.size.height))
        loadMoreFooterView.delegate = self
        loadMoreFooterView.backgroundColor = UIColor.clearColor()
        tableView.addSubview(loadMoreFooterView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        hideSideMenuView()
        
        AppData.RendezvousData.wipeSelectedRsData()
        tableRefresher.endRefreshing()
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if AppStatus.RendezvousStatus.tableShouldRefresh {
            rsTableAutoRefresh()
        }else{
            if let i = cameBackFromIndexPath {
                tableView.reloadRowsAtIndexPaths([i], withRowAnimation: UITableViewRowAnimation.None)
                cameBackFromIndexPath = nil
            }
        }
    }
    
    
    // MARK: - Data Query
    func rsTableAutoRefresh(){
        tableRefresher.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.tableRefresher.frame.height
                }, completion: nil)
        }
        rsRefreshSelectorCacheFirst()
    }
    
    func rsRefreshSelector() {
        print("Rendezvous Begin Refreshing")
        AppStatus.RendezvousStatus.tableShouldRefresh = false
        allowLoadingMore = false
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.RENDEZVOUS.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.limit = SINGLE_LOAD_AMOUNT
        queryCompletionCounter = 2
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error, removeAll: true)
            self.queryCompletionUIHandler(error: error)
            self.allowLoadingMore = true
        }
    }
    
    func rsRefreshSelectorCacheFirst() {
        print("Rendezvous Begin Refreshing With Cache")
        AppStatus.RendezvousStatus.tableShouldRefresh = false
        allowLoadingMore = false
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.RENDEZVOUS.AUTHOR)
        query.limit = SINGLE_LOAD_AMOUNT
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter++
            self.queryCompletionDataHandler(result: result,error: error, removeAll: true)
            self.queryCompletionUIHandler(error: error)
            if self.queryCompletionCounter >= 2 {
                self.allowLoadingMore = true
            }
        }
    }
    
    func rsLoadMoreSelector() {
        print("Rendezvous Begin Loading More")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.RENDEZVOUS.AUTHOR)
        query.limit = SINGLE_LOAD_AMOUNT
        query.skip = skipAmount
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error, removeAll: false)
            self.doneLoadingMoreTableViewData()
        }
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {
            /*
            self.view.makeToast(message: "Fetching rendezvous", duration: 1.0, position: HRToastPositionCenterAbove)*/
            return
        }
        if self.queryCompletionCounter >= 2 {
            tableRefresher.endRefreshing()
            if error == nil{
                /*
                self.view.makeToast(message: "Refresh succeeded", duration: 0.5, position: HRToastPositionCenterAbove)*/
                AppStatus.RendezvousStatus.lastRefreshTime = NSDate()
            }else{
                self.view.makeToast(message: "Refresh failed. Please try again later.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result:[AnyObject]!, error:NSError!, removeAll:Bool) {
        print("Rendezvous query completed for the \(self.queryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            if removeAll {
                rdzvs.removeAll(keepCapacity: true)
                skipAmount = 0
            }
            couldLoadMore = result.count >= SINGLE_LOAD_AMOUNT
            skipAmount += result.count
            print("Find \(result.count) results.")
            for re in result as! [PFObject]{
                if let newRs = Rendezvous(parseObject: re) {
                    rdzvs.append(newRs)
                }
            }
            beginFilter()
            tableView.reloadData()
        }else{
            print("query error: (error)")
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filteredRs.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_RsCell, forIndexPath: indexPath) as! RendezvousCell
        cell.initWithRs(filteredRs[indexPath.section], fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! RendezvousCell
        AppData.RendezvousData.selectedRendezvous = cell.childRs
        cameBackFromIndexPath = indexPath
        self.performSegueWithIdentifier(SegueID_RsDetail, sender: self)
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
        rsLoadMoreSelector()
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
    
    
    // MARK: - ENSideMenu Delegate
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("shouldNotOpenSideMenuRs")
        return false
    }
}

