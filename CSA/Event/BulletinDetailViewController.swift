//
//  BulletinDetailViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/14/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class BulletinDetailViewController: UIViewController, ENSideMenuDelegate {
    
    var selectedBulletin:Bulletin!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var txtviewDetail: UITextView!
    
    @IBOutlet weak var ctSubtitleHeight: NSLayoutConstraint!
    @IBOutlet weak var ctWhenHeight: NSLayoutConstraint!
    @IBOutlet weak var ctWhereHeight: NSLayoutConstraint!
    @IBOutlet weak var ctSubtitleTop: NSLayoutConstraint!
    @IBOutlet weak var ctWhenTop: NSLayoutConstraint!
    @IBOutlet weak var ctWhereTop: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedBulletin = AppData.BulletinData.selectedBulletin
        
        //required
        self.title = selectedBulletin.title
        lblTitle.text = selectedBulletin.title
        txtviewDetail.text = selectedBulletin.detail
        
        //optional
        if let subtitle = selectedBulletin.subtitle {
            ctSubtitleTop.constant = 2
            ctSubtitleHeight.constant = 20
            lblSubtitle.hidden = false
            lblSubtitle.text = subtitle
        }else{
            ctSubtitleTop.constant = 0
            ctSubtitleHeight.constant = 0
            lblSubtitle.hidden = true
        }
        if let date = selectedBulletin.date{
            ctWhenTop.constant = 2
            ctWhenHeight.constant = 20
            lblWhen.hidden = false
            lblWhen.text = AppTools.formatDateWithWeekDay(date)
        }else{
            ctWhenTop.constant = 0
            ctWhenHeight.constant = 0
            lblWhen.hidden = true
        }
        if let location = selectedBulletin.location {
            ctWhereTop.constant = 2
            ctWhereHeight.constant = 20
            lblWhere.hidden = false
            lblWhere.text = location
        }else{
            ctWhereTop.constant = 0
            ctWhereHeight.constant = 0
            lblWhere.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.EventStatus.currentlyDisplayedView = AppStatus.EventStatus.ViewName.Detail
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.EventStatus.ViewName.Detail.rawValue)
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
