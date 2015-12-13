//
//  BulletinDetailViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/14/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class BulletinDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ENSideMenuDelegate {
    
    var selectedBulletin:Bulletin!

    @IBOutlet weak var tableView: UITableView!
    
    let ReuseID_Main = "IDMainPostCell"
    let ReuseID_Title = "IDTitleCell"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedBulletin = AppData.BulletinData.selectedBulletin
        initUI()
    }
    
    func initUI() {
        self.title = selectedBulletin.title
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //refreshControl = UIRefreshControl()
        //tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.EventStatus.currentlyDisplayedView = AppStatus.EventStatus.ViewName.Detail
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.EventStatus.ViewName.Detail.rawValue)
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
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_Title, forIndexPath: indexPath) as! BulletinTitleCell
            cell.initWithBulletin(selectedBulletin)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_Main, forIndexPath: indexPath) as! BulletinDetailMainCell
            cell.initWithBulletin(selectedBulletin)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("gg", forIndexPath: indexPath)
            return cell
        }
    }
    
    deinit{
        print("Release - EventDetailViewController")
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("ShouldNotOpenSideMenu")
        return false
    }
    
}
