//
//  EventDetailViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/7/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController, ENSideMenuDelegate {

    var selectedEvent:Event!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var txtviewDetail: UITextView!

    // ******<Navigation Item>*******
    @IBAction func onClickMore(sender: AnyObject) {
        self.sideMenuController()?.sideMenu?.showSideMenu()
    }
    // ******</Navigation Item>*******
    
    // ******<Life Cycle>*******
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedEvent = AppData.EventData.selectedEvent
        
        self.title = selectedEvent.title
        lblTitle.text = selectedEvent.title
        lblWhen.text = "When: \(AppTools.formatDateWithWeekDay(selectedEvent.date))"
        lblWhere.text = "Where: \(selectedEvent.location)"
        txtviewDetail.text = selectedEvent.detail
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
    // ******</Life Cycle>*******
    
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
