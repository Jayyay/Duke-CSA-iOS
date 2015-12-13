//
//  EventDetailViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/7/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ENSideMenuDelegate {

    var selectedEvent:Event!
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl!
    
    let ReuseID_Main = "IDMainPostCell"
    let ReuseID_Title = "IDTitleCell"
    
    
    @IBAction func onClickMore(sender: AnyObject) {
        self.sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    // MARK: - Life Cycle
    
    func initUI() {
        self.title = selectedEvent.title
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        //refreshControl = UIRefreshControl()
        //tableView.addSubview(refreshControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedEvent = AppData.EventData.selectedEvent
        initUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.EventStatus.currentlyDisplayedView = AppStatus.EventStatus.ViewName.Detail
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.EventStatus.ViewName.Detail.rawValue)
    }
    
    deinit{
        AppData.EventData.signupVC = nil
        AppData.EventData.discussVC = nil
        print("Release - EventDetailViewController")
    }
    
    // MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_Title, forIndexPath: indexPath) as! EventTitleCell
            cell.initWithEvent(selectedEvent)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_Main, forIndexPath: indexPath) as! EventDetailMainCell
            cell.initWithEvent(selectedEvent)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("gg", forIndexPath: indexPath)
            return cell
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
        print("sideMenuShouldOpenSideMenu")
        return true
    }

}
