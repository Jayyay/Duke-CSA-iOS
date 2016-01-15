//
//  RsLikeTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class RsLikeTableViewController: UITableViewController, ENSideMenuDelegate {

    @IBOutlet weak var lblLikeNumber: UILabel!
    var likes:[PFUser] = []
    var selectedRs:Rendezvous!
    var queryCompletionCounter = 0
    
    let ReuseID_BasicUserCell = "IDLikeCell"
    
    func initUI(){
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66
        refreshControl = UIRefreshControl()
        //refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl!.addTarget(self, action: Selector("rsLikeRefreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        
        let nib = UINib(nibName: "BasicUserCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_BasicUserCell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppData.RendezvousData.likeVC = self
        selectedRs = AppData.RendezvousData.selectedRendezvous
        
        initUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.RendezvousStatus.currentlyDisplayedView = AppStatus.RendezvousStatus.ViewName.Like
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.RendezvousStatus.ViewName.Like.rawValue)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //if selectedRs.refreshLikesNeeded {}
        rsLikeAutoRefresh()
    }
    deinit{
        print("Release - RsLikeTableViewController")
    }
    
    // MARK: - Data Query
    func rsLikeAutoRefresh(){
        /*refreshControl!.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.refreshControl!.frame.height
                }, completion: nil)
        }*/
        rsLikeRefreshSelectorCacheFirst()
    }
    
    func rsLikeRefreshSelectorCacheFirst() {
        print("RsLike Begin Refreshing Cache First")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.includeKey(PFKey.RENDEZVOUS.LIKES)
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.getObjectInBackgroundWithId(selectedRs.PFInstance.objectId!, block: {(result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionCounter++
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func rsLikeRefreshSelector() {
        print("RsLike Begin Refreshing")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.includeKey(PFKey.RENDEZVOUS.LIKES)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        self.queryCompletionCounter = 2
        query.getObjectInBackgroundWithId(selectedRs.PFInstance.objectId!, block: {(result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {return}
        if self.queryCompletionCounter >= 2 {
            refreshControl!.endRefreshing()
            if error != nil{
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result:PFObject!, error:NSError!) {
        print("Likes query completed with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            likes = result[PFKey.RENDEZVOUS.LIKES] as! [PFUser]
            lblLikeNumber.text = "\(likes.count) " + (likes.count < 2 ? "Like" : "Likes")
            tableView.reloadData()
        }else{
            print("query error: \(error) ", terminator: "")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_BasicUserCell, forIndexPath: indexPath) as! BasicUserCell
        cell.initWithUser(likes[indexPath.row], fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AppFunc.displayUserInfo(likes[indexPath.row], fromVC: self)
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        return true
    }

}
