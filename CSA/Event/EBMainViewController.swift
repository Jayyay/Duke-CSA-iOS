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
    
    var needRefreshCurrentUser = true
    
    var eventTableRefresher: UIRefreshControl!
    var currentTableView: UITableView!
    
    var eventQueryCompletionCounter = 0
    
    //Cell reuse ID
    let ReuseID_EventCell = "IDEventCell"
    
    //Segue ID
    let SegueID_eventDetail = "eventDetailSegue"
    
    //adapter array
    var events:[Event] = []
    
    let EVENT_SINGLE_LOAD_AMOUNT:Int = 8
    var EVENT_SKIP_AMOUNT:Int = 0
    var eventLoadMoreFooterView: LoadMoreTableFooterView!
    var eventAllowLoadingMore = true
    var eventIsLoadingMore: Bool = false
    var eventCouldLoadMore: Bool = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad - EventTableViewController")
        generalInitUI()
        eventTableInitUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        hideSideMenuView()
        
        AppData.EventData.wipeSelectedEventData()
        eventTableRefresher?.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("event view did appear")
        
        if PFUser.currentUser() == nil{
            print("not logged in")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardID.LOGIN) as! LoginViewController
            self.presentViewController(vc, animated: true, completion: nil)
            return
        }
        else {
            let id = PFUser.currentUser()!.objectId!
            let query = PFQuery(className: "_User")
            query.getObjectInBackgroundWithId(id, block: { (user, error) in
                if (user == nil) {
                    let alertController = UIAlertController(title: "Error", message: "Due to a stupid developer's mistake, please log in again to fix your account issues.", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(StoryboardID.LOGIN) as! LoginViewController
                        self.presentViewController(vc, animated: true, completion: nil)
                    })
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
            })
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
            eventTableRefreshSelector()
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
    
    // MARK: - Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_EventCell, forIndexPath: indexPath) as! EventCell
        cell.initWithEvent(events[indexPath.section], fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AppData.EventData.selectedEvent = (tableView.cellForRowAtIndexPath(indexPath) as! EventCell).childEvent
        self.performSegueWithIdentifier(SegueID_eventDetail, sender: self)
    }
    
    // MARK: - Pull to load more
    // LoadMoreTableFooterViewDelegate
    func loadMoreTableFooterDidTriggerRefresh(view: LoadMoreTableFooterView) {
        eventloadMoreTableViewDataSource()
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
    
    func doneEventLoadingMoreTableViewData() {
        eventIsLoadingMore = false
        eventLoadMoreFooterView.loadMoreScrollViewDataSourceDidFinishedLoading()
    }
    
    // UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (eventAllowLoadingMore && eventCouldLoadMore) {
            eventLoadMoreFooterView.loadMoreScrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (eventAllowLoadingMore && eventCouldLoadMore) {
            eventLoadMoreFooterView.loadMoreScrollViewDidEndDragging(scrollView)
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
