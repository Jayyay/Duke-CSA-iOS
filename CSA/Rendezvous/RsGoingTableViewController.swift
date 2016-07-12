//
//  RsGoingTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class RsGoingTableViewController: UITableViewController, ENSideMenuDelegate {

    @IBOutlet weak var lblGoingNumber: UILabel!
    var goings: [PFUser] = []
    var selectedRs:Rendezvous!
    var queryCompletionCounter = 0
    
    let ReuseID_BasicUserCell = "IDGoingCell"
    
    func initUI(){
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(RsGoingTableViewController.rsGoingRefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        
        let nib = UINib(nibName: "BasicUserCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_BasicUserCell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppData.RendezvousData.goingVC = self
        selectedRs = AppData.RendezvousData.selectedRendezvous
        
        initUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.RendezvousStatus.currentlyDisplayedView = AppStatus.RendezvousStatus.ViewName.Going
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.RendezvousStatus.ViewName.Going.rawValue)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rsGoingAutoRefresh()
    }
    deinit{
        print("Release - RsGoingTableViewController")
    }
    
    
    // MARK: - Data Query
    func rsGoingAutoRefresh(){
        rsGoingRefreshSelector()
    }
    
    func rsGoingRefreshSelectorCacheFirst() {
        print("RsGoing Begin Refreshing Cache First")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        query.includeKey(PFKey.RENDEZVOUS.GOINGS)
        self.queryCompletionCounter = 0
        query.getObjectInBackgroundWithId(selectedRs.PFInstance.objectId!, block: {(result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionCounter += 1
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func rsGoingRefreshSelector() {
        print("RsGoing Begin Refreshing")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.includeKey(PFKey.RENDEZVOUS.GOINGS)
        self.queryCompletionCounter = 2
        query.getObjectInBackgroundWithId(selectedRs.PFInstance.objectId!, block: {(result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result, error: error)
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
        print("Goings query completed with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            goings = result[PFKey.RENDEZVOUS.GOINGS] as! [PFUser]
            self.lblGoingNumber.text = "\(self.goings.count) " + (self.goings.count < 2 ? "Going" : "Goings")
            self.tableView.reloadData()
        }else{
            print("query error: \(error) ", terminator: "")
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_BasicUserCell, forIndexPath: indexPath) as! BasicUserCell
        cell.initWithUser(goings[indexPath.row], fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AppFunc.displayUserInfo(goings[indexPath.row], fromVC: self)
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        return true
    }
}
