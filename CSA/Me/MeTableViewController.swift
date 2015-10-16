//
//  MeTableViewController.swift
//  CSA
//
//  Created by Zhe Wang on 4/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class MeTableViewController: UITableViewController {
    
    let SegueID_MyProfile = "MyProfileSegue"
    
    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAboutMe: UILabel!
    
    func initUI(){
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
        reloadProfile()
    }
    
    func adminOperationRememberToRemove() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        adminOperationRememberToRemove()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AppStatus.MeTableStatus.tableShouldRefreshLocally {
            reloadProfile()
        }
    }
    
    deinit{
        print("Release - MeTableViewController")
    }

    // MARK: - Customs
    func displayLogoutAlert(){
        let str = "Are you sure you want to log out?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default) { _ in
            self.userLogout()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { _ in
        }
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func userLogout(){
        PFInstallation.currentInstallation()[PFKey.INSTALL.BINDED_USER] = NSNull()
        PFInstallation.currentInstallation().saveInBackground()
        PFUser.logOut()
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.LOGIN) as! LoginViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func reloadProfile(){
        AppFunc.downloadPropicFromParse(user: PFUser.currentUser()!, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        lblName.text = PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as? String
        lblAboutMe.text = PFUser.currentUser()![PFKey.USER.ABOUT_ME] as? String
    }
    
    // MARK: - Table view
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section{
        case 0:
            //self.performSegueWithIdentifier(SegueID_myInfo, sender: self)
            break
        case 1:
            break
            //self.performSegueWithIdentifier(SegueID_func[indexPath.row], sender: self)
        case 2:
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            displayLogoutAlert()
        default:
            break
        }
    }
   
    override func shouldAutorotate() -> Bool {
        return false
    }
}
