//
//  MeNotifTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class MeNotifTableViewController: UITableViewController {

    let ReuseID_NotifCell = "IDNotifCell"
    var queryCompletionCounter = 0
    var notifications:[Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(MeNotifTableViewController.refreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        tableAutoRefresh()
    }

    // MARK: - Data Query
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
        print("Notification Begin Refreshing Cache First")
        let query = PFQuery(className: PFKey.NOTIFICATION.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.NOTIFICATION.USER, equalTo: PFUser.currentUser()!)
        query.orderByDescending(PFKey.CREATED_AT)
        query.limit = 20
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter += 1
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        }
    }
    
    func refreshSelector() {
        print("Notification Begin Refreshing")
        let query = PFQuery(className: PFKey.NOTIFICATION.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.NOTIFICATION.USER, equalTo: PFUser.currentUser()!)
        query.orderByDescending(PFKey.CREATED_AT)
        query.limit = 20
        query.cachePolicy = PFCachePolicy.NetworkOnly
        self.queryCompletionCounter = 2
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter += 1
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
        print("Notification completed for the \(queryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) results.")
            if let arr = result {
                notifications.removeAll(keepCapacity: true)
                for n in arr {
                    if let newNotif = Notification(parseObject: n) {
                        notifications.append(newNotif)
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
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_NotifCell, forIndexPath: indexPath) as! MeNotifCell
        cell.initWithNotif(notifications[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MeNotifCell
        cell.getSelected()
    }

}
