//
//  ProfileTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 6/15/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var lblTitleAbout: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblBday: UILabel!
    
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMajor: UILabel!
    @IBOutlet weak var lblMinor: UILabel!
    @IBOutlet weak var lblNetID: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblRelationship: UILabel!
    @IBOutlet weak var tvAbout: UITextView!
    
    @IBAction func onEdit(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.PROFILE_EDIT) as! ProfileEditTableViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
        tvAbout.layer.cornerRadius = 5.0
        tvAbout.layer.masksToBounds = true
        tvAbout.layer.borderColor = UIColor.blackColor().CGColor
        tvAbout.layer.borderWidth = 0.5
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let u = PFUser.currentUser()!
        AppFunc.downloadPropicFromParse(user: u, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        lblName.text = u[PFKey.USER.DISPLAY_NAME] as? String
        lblGender.text = u[PFKey.USER.GENDER] as? String
        lblBday.text = u[PFKey.USER.BIRTHDAY] as? String
        lblYear.text = u[PFKey.USER.WHICH_YEAR] as? String
        lblMajor.text = u[PFKey.USER.MAJOR] as? String
        lblMinor.text = u[PFKey.USER.MINOR] as? String
        lblNetID.text = u[PFKey.USER.NET_ID] as? String
        lblEmail.text = u[PFKey.USER.EMAIL] as? String
        lblPhone.text = u[PFKey.USER.CELL_PHONE] as? String
        lblRelationship.text = u[PFKey.USER.RELATIONSHIP] as? String
        tvAbout.text = u[PFKey.USER.ABOUT_ME] as? String
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        return 44
    }
    
}
