//
//  MyNavigationController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 30.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class EventNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up side menu
        let menuTableVC = EventMenuTableViewController()
        menuTableVC.sourceNavigationController = self
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: menuTableVC, menuPosition:.Right)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 250.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false
        view.bringSubviewToFront(navigationBar) // make navigation bar showing over side menu
        
        if let info = AppData.NotifData.notifInfo {
            print(info.events)
            self.tabBarItem.badgeValue = info.events.count == 0 ? nil : String(info.events.count)
        }
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }

}
