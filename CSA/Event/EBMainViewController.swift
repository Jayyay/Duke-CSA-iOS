//
//  EBMainViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/13/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EBMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ENSideMenuDelegate, LoadMoreTableFooterViewDelegate {
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var bulletinTableView: UITableView!
    
    var needRefreshCurrentUser = true
    
    var eventTableRefresher: UIRefreshControl!
    var bulletinTableRefresher: UIRefreshControl!
    
    
    var currentTableView: UITableView!
    
    var eventQueryCompletionCounter = 0
    var bulletinQueryCompletionCounter = 0
    
    
    //Cell reuse ID
    let ReuseID_EventCell = "IDEventCell"
    let ReuseID_BulletinCell = "IDBulletinCell"
    
    //Segue ID
    let SegueID_eventDetail = "eventDetailSegue"
    let SegueID_bulletinDetail = "bulletinDetailSegue"
    
    //adapter array
    var events:[Event] = []
    var bulletins:[Bulletin] = []
    
    let EVENT_SINGLE_LOAD_AMOUNT:Int = 8
    var EVENT_SKIP_AMOUNT:Int = 0
    var eventLoadMoreFooterView: LoadMoreTableFooterView!
    var eventAllowLoadingMore = true
    var eventIsLoadingMore: Bool = false
    var eventCouldLoadMore: Bool = false
    
    let BULLETIN_SINGLE_LOAD_AMOUNT:Int = 8
    var BULLETIN_SKIP_AMOUNT:Int = 0
    var bulletinLoadMoreFooterView: LoadMoreTableFooterView!
    var bulletinAllowLoadingMore = true
    var bulletinIsLoadingMore: Bool = false
    var bulletinCouldLoadMore: Bool = false
    
    // MARK: - Segment control deprecated
    /*
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    @IBAction func segIndexChanged(sender: AnyObject) {
        shouldPresentViewOfSegIndex(segCtrl.selectedSegmentIndex, reload: true)
    }
    
    func shouldPresentViewOfSegIndex(index:Int, reload:Bool){
        switch index{
        case 0:
            if currentTableView != nil && currentTableView == eventTableView{
                return
            }
            currentTableView = eventTableView
            eventTableView.hidden = false
            bulletinTableView.hidden = true
            self.title = "Events"
        case 1:
            if currentTableView != nil && currentTableView == bulletinTableView{
                return
            }
            currentTableView = bulletinTableView
            bulletinTableView.hidden = false
            eventTableView.hidden = true
            self.title = "Bulletins"
        default:
            break
        }
    }*/
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad - EventTableViewController")
        generalInitUI()
        eventTableInitUI()
        //bulletinTableInit()
        //shouldPresentViewOfSegIndex(0, reload: false)
        //segCtrl.layer.cornerRadius = 3.0
        //segCtrl.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        hideSideMenuView()
        
        AppData.EventData.wipeSelectedEventData()
        //AppData.BulletinData.wipeSelectedBulletinData()
        eventTableRefresher?.endRefreshing()
        //bulletinTableRefresher?.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
        }
        
        print("event view did appear")
        
        if PFUser.currentUser() == nil{
            print("not logged in")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardID.LOGIN) as! LoginViewController
            self.presentViewController(vc, animated: true, completion: nil)
            return
        }
        
        if needRefreshCurrentUser {
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (o:PFObject?, error:NSError?) -> Void in
                if error == nil {
                    print("Current user refreshed successfully")
                    self.needRefreshCurrentUser = false
                }
            })
        }
        
        if AppStatus.EventStatus.tableShouldRefresh {
            eventTableAutoRefresh()
        }
        if AppStatus.BulletinStatus.tableShouldRefresh {
            //bulletinTableAutoRefresh()
        }
        
    }
    
    deinit{
        print("Release - EventTableViewController")
    }
    
    
    func generalInitUI(){
        self.title = "Events"
    }
    
    // MARK: - Events
    func eventTableInitUI(){
        currentTableView = eventTableView
        eventTableView.rowHeight = UITableViewAutomaticDimension
        eventTableView.estimatedRowHeight = 100
        
        let nib = UINib(nibName: "EventCellNib", bundle: nil)
        eventTableView.registerNib(nib, forCellReuseIdentifier: ReuseID_EventCell)
        
        eventTableRefresher = UIRefreshControl()
        //eventTableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        eventTableRefresher.addTarget(self, action: #selector(eventTableRefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        eventTableView.addSubview(eventTableRefresher)
        
        eventLoadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, eventTableView.contentSize.height, eventTableView.frame.size.width, eventTableView.frame.size.height))
        eventLoadMoreFooterView.delegate = self
        eventLoadMoreFooterView.backgroundColor = UIColor.clearColor()
        eventTableView.addSubview(eventLoadMoreFooterView)
    }
    
    func eventTableAutoRefresh(){
        print("EventAutoRefresh")
        eventTableRefresher.beginRefreshing()
        if eventTableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.eventTableView.contentOffset.y = -self.eventTableRefresher.frame.height
                }, completion: nil)
        }
        eventTableRefreshSelector()
    }
    
    func eventTableRefreshSelector() {
        print("Event Begin Refreshing")
        AppStatus.EventStatus.tableShouldRefresh = false
        AppStatus.EventStatus.lastRefreshTime = NSDate()
        eventAllowLoadingMore = false
        let query = PFQuery(className: PFKey.EVENT.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.orderByDescending(PFKey.CREATED_AT)
        query.limit = EVENT_SINGLE_LOAD_AMOUNT
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.eventQueryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.eventQueryCompletionCounter += 1
            self.eventQueryCompletionDataHandler(result: result,error: error, removeAll: true)
            self.eventQueryCompletionUIHandler(error: error)
            if self.eventQueryCompletionCounter >= 2 {
                self.eventAllowLoadingMore = true
            }
        }
    }
    
    func eventLoadMoreSelector() {
        print("Event Begin Loading More")
        let query = PFQuery(className: PFKey.EVENT.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.limit = EVENT_SINGLE_LOAD_AMOUNT
        query.skip = EVENT_SKIP_AMOUNT
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.eventQueryCompletionDataHandler(result: result, error: error, removeAll: false)
            self.doneEventLoadingMoreTableViewData()
        }
    }
    
    func eventQueryCompletionUIHandler(error error:NSError!){
        if self.eventQueryCompletionCounter == 1 {
            /*if currentTableView == eventTableView {
                self.view.makeToast(message: "Fetching events", duration: 1.0, position: HRToastPositionCenterAbove)
            }*/
            return
        }
        if self.eventQueryCompletionCounter >= 2 {
            eventTableRefresher!.endRefreshing()
            if error == nil{
                /*if currentTableView == eventTableView {
                    self.view.makeToast(message: "Events refresh succeeded", duration: 0.5, position: HRToastPositionCenterAbove)
                }*/
                AppStatus.EventStatus.lastRefreshTime = NSDate()
            }else{
                if currentTableView == eventTableView {
                    self.view.makeToast(message: "Events refresh failed. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
                }
            }
        }
    }
    func eventQueryCompletionDataHandler(result result:[PFObject]!, error:NSError!, removeAll:Bool){
        print("Event query completed for the \(self.eventQueryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            if removeAll {
                events.removeAll(keepCapacity: true)
                EVENT_SKIP_AMOUNT = 0
            }
            eventCouldLoadMore = result.count >= EVENT_SINGLE_LOAD_AMOUNT
            EVENT_SKIP_AMOUNT += result.count
            print("Find \(result.count) events.")
            for re in result{
                if let newEvent = Event(parseObject:re) {
                    events.append(newEvent)
                }
            }
            eventTableView.reloadData()
        }else{
            print("query error: \(error)")
        }
    }
    
    
    // MARK: - Bulletins
    func bulletinTableInit(){
        let nib = UINib(nibName: "BulletinCellNib", bundle: nil)
        bulletinTableView.rowHeight = UITableViewAutomaticDimension
        bulletinTableView.estimatedRowHeight = 100
        bulletinTableView.registerNib(nib, forCellReuseIdentifier: ReuseID_BulletinCell)
        bulletinTableRefresher = UIRefreshControl()
        //bulletinTableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        bulletinTableRefresher.addTarget(self, action: #selector(bulletinTableRefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        bulletinTableView.addSubview(bulletinTableRefresher)
        
        bulletinLoadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, bulletinTableView.contentSize.height, bulletinTableView.frame.size.width, bulletinTableView.frame.size.height))
        bulletinLoadMoreFooterView.delegate = self
        bulletinLoadMoreFooterView.backgroundColor = UIColor.clearColor()
        bulletinTableView.addSubview(bulletinLoadMoreFooterView)
    }
    
    func bulletinTableAutoRefresh(){
        print("BulletinAutoRefresh")
        if bulletinTableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.bulletinTableView.contentOffset.y = -self.bulletinTableRefresher.frame.height
                }, completion: nil)
        }
        bulletinTableRefresher.beginRefreshing()
        bulletinTableRefreshSelector()
    }
    
    func bulletinTableRefreshSelector() {
        AppStatus.BulletinStatus.tableShouldRefresh = false
        print("Bulletin Begin Refreshing")
        AppStatus.BulletinStatus.lastRefreshTime = NSDate()
        let query = PFQuery(className: PFKey.BULLETIN.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.orderByDescending(PFKey.CREATED_AT)
        query.limit = BULLETIN_SINGLE_LOAD_AMOUNT
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.bulletinQueryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.bulletinQueryCompletionCounter += 1
            self.bulletinQueryCompletionDataHandler(result: result,error: error, removeAll: true)
            self.bulletinQueryCompletionUIHandler(error: error)
            if self.bulletinQueryCompletionCounter >= 2 {
                self.bulletinAllowLoadingMore = true
            }
        }
    }
    
    func bulletinLoadMoreSelector() {
        print("Bulletin Begin Loading More")
        let query = PFQuery(className: PFKey.BULLETIN.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.limit = BULLETIN_SINGLE_LOAD_AMOUNT
        query.skip = BULLETIN_SKIP_AMOUNT
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.bulletinQueryCompletionDataHandler(result: result, error: error, removeAll: false)
            self.doneBulletinLoadingMoreTableViewData()
        }
    }
    
    func bulletinQueryCompletionUIHandler(error error:NSError!){
        if self.bulletinQueryCompletionCounter == 1 {
            /*if currentTableView == bulletinTableView{
                self.view.makeToast(message: "Fetching bulletins data", duration: 1.0, position: HRToastPositionCenterAbove)
            }*/
            return
        }
        if self.bulletinQueryCompletionCounter >= 2 {
            bulletinTableRefresher.endRefreshing()
            if error == nil{
                /*if currentTableView == bulletinTableView {
                    self.view.makeToast(message: "Bulletins refresh succeeded", duration: 0.5, position: HRToastPositionCenterAbove)
                }*/
                AppStatus.BulletinStatus.lastRefreshTime = NSDate()
            }else{
                if currentTableView == bulletinTableView {
                    self.view.makeToast(message: "Bulletins refresh failed. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
                }
            }
        }
    }
    func bulletinQueryCompletionDataHandler(result result:[PFObject]!, error:NSError!, removeAll:Bool){
        print("Bulletin query completed for the \(self.bulletinQueryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            if removeAll {
                bulletins.removeAll(keepCapacity: true)
                BULLETIN_SKIP_AMOUNT = 0
            }
            bulletinCouldLoadMore = result.count >= BULLETIN_SINGLE_LOAD_AMOUNT
            BULLETIN_SKIP_AMOUNT += result.count
            print("Find \(result.count) bulletins.")
            for re in result {
                if let newBulletin = Bulletin(parseObject: re){
                    bulletins.append(newBulletin)
                }
            }
            bulletinTableView.reloadData()
        }else{
            print("query error: \(error)", terminator: "")
        }
    }
    
    
    
    // MARK: - Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == eventTableView {
            return events.count
        }else{
            return bulletins.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == eventTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_EventCell, forIndexPath: indexPath) as! EventCell
            cell.initWithEvent(events[indexPath.section], fromTableView: tableView, forIndexPath: indexPath)
            //AppFunc.setCellTransparent(cell)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_BulletinCell, forIndexPath: indexPath) as! BulletinCell
            cell.initWithBulletin(bulletins[indexPath.section])
            //AppFunc.setCellTransparent(cell)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == eventTableView {
            AppData.EventData.selectedEvent = (tableView.cellForRowAtIndexPath(indexPath) as! EventCell).childEvent
            self.performSegueWithIdentifier(SegueID_eventDetail, sender: self)
        }else{
            AppData.BulletinData.selectedBulletin = (tableView.cellForRowAtIndexPath(indexPath) as! BulletinCell).childBulletin
            self.performSegueWithIdentifier(SegueID_bulletinDetail, sender: self)
        }
        
    }
    
    // MARK: - Pull to load more
    // LoadMoreTableFooterViewDelegate
    func loadMoreTableFooterDidTriggerRefresh(view: LoadMoreTableFooterView) {
        if currentTableView == eventTableView {
            eventloadMoreTableViewDataSource()
        }else {
            bulletinloadMoreTableViewDataSource()
        }
    }
    
    func loadMoreTableFooterDataSourceIsLoading(view: LoadMoreTableFooterView) -> Bool {
        if currentTableView == eventTableView {
            return eventIsLoadingMore
        }else{
            return bulletinIsLoadingMore
        }
    }
    
    func eventloadMoreTableViewDataSource() {
        if eventIsLoadingMore {return}
        eventIsLoadingMore = true
        eventLoadMoreSelector()
    }
    
    func bulletinloadMoreTableViewDataSource() {
        if bulletinIsLoadingMore {return}
        bulletinIsLoadingMore = true
        bulletinLoadMoreSelector()
    }
    
    func doneEventLoadingMoreTableViewData() {
        eventIsLoadingMore = false
        eventLoadMoreFooterView.loadMoreScrollViewDataSourceDidFinishedLoading()
    }

    func doneBulletinLoadingMoreTableViewData() {
        bulletinIsLoadingMore = false
        bulletinLoadMoreFooterView.loadMoreScrollViewDataSourceDidFinishedLoading()
    }
    
    // UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if currentTableView == eventTableView {
            if (eventAllowLoadingMore && eventCouldLoadMore) {
                eventLoadMoreFooterView.loadMoreScrollViewDidScroll(scrollView)
            }
        }else {
            if (bulletinAllowLoadingMore && bulletinCouldLoadMore) {
                bulletinLoadMoreFooterView.loadMoreScrollViewDidScroll(scrollView)
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if currentTableView == eventTableView {
            if (eventAllowLoadingMore && eventCouldLoadMore) {
                eventLoadMoreFooterView.loadMoreScrollViewDidEndDragging(scrollView)
            }
        }else {
            if (bulletinAllowLoadingMore && bulletinCouldLoadMore) {
                bulletinLoadMoreFooterView.loadMoreScrollViewDidEndDragging(scrollView)
            }
        }
    }
    
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("shouldNotOpenSideMenu")
        return false
    }
    
}
