//
//  UserProfileTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 5/7/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class UserProfileTableViewController: UITableViewController {
    
    var user:PFUser!
    
    
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
    
    override func viewDidLoad() {
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
        
        if let gender = user[PFKey.USER.GENDER] as? String{
            switch gender {
            case "male" :
                lblTitleAbout.text = "About him"
            case "female":
                lblTitleAbout.text = "About her"
            default:
                lblTitleAbout.text = "About"
            }
        }else{
           lblTitleAbout.text = "About"
        }
        
        tvAbout.layer.cornerRadius = 5.0
        tvAbout.layer.masksToBounds = true
        tvAbout.layer.borderColor = UIColor.blackColor().CGColor
        tvAbout.layer.borderWidth = 0.5
        
        lblName.text = user[PFKey.USER.DISPLAY_NAME] as? String
        lblGender.text = user[PFKey.USER.GENDER] as? String
        lblBday.text = user[PFKey.USER.BIRTHDAY] as? String
        lblYear.text = user[PFKey.USER.WHICH_YEAR] as? String
        lblMajor.text = user[PFKey.USER.MAJOR] as? String
        lblMinor.text = user[PFKey.USER.MINOR] as? String
        lblNetID.text = user[PFKey.USER.NET_ID] as? String
        lblEmail.text = user[PFKey.USER.EMAIL] as? String
        lblPhone.text = user[PFKey.USER.CELL_PHONE] as? String
        lblRelationship.text = user[PFKey.USER.RELATIONSHIP] as? String
        tvAbout.text = user[PFKey.USER.ABOUT_ME] as? String
        AppFunc.downloadPropicFromParse(user: user, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        return 44
    }
    
    deinit{
        print("release - UserProfileTableViewController")
    }
    
}
