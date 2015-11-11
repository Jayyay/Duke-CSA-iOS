//
//  RsNavigationController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class RsNavigationController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up side menu
        let menuTableVC = RsMenuTableViewController()
        menuTableVC.sourceNavigationController = self
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: menuTableVC, menuPosition:.Right)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 250.0 // optional, default is 160
        sideMenu?.bouncingEnabled = false
        view.bringSubviewToFront(navigationBar) // make navigation bar showing over side menu
    }
    
}
