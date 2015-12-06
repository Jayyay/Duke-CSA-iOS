//
//  AppFunc.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/22/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
import Parse

struct AppFunc{
    static func pauseApp() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    static func resumeApp() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    static func displayUserInfo(user:PFUser, fromVC:UIViewController) {
        let vc = fromVC.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.USER_INFO) as! UserProfileTableViewController
        vc.user = user
        vc.title = user[PFKey.USER.DISPLAY_NAME] as? String
        fromVC.navigationController?.pushViewController(vc, animated: true)
        
        print("reach here")
    }
    static func setCellTransparent(cell:UITableViewCell) {
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView = UIView()
        cell.selectedBackgroundView = UIView()
    }
    static func downloadPropicFromParse(user user:PFUser, saveToImgView:UIImageView, inTableView tableView:UITableView!, forIndexPath indexPath:NSIndexPath!) {
        saveToImgView.image = UIImage(named: "placeholder-user")
        if let propicFile = user[PFKey.USER.PROPIC_COMPRESSED] as? PFFile {
            propicFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                if let d = data {
                    if tableView != nil && indexPath != nil && tableView.cellForRowAtIndexPath(indexPath) != nil {//cell in table is visible
                        dispatch_async(dispatch_get_main_queue(), { _ in
                            saveToImgView.image = UIImage(data: d)
                        })
                    }
                }else{
                    print("Can't retrieve propic: \(error)")
                }
            })
        }
    }
    static func refreshCheck(){
        if let lastEventRefreshTime = AppStatus.EventStatus.lastRefreshTime {
            let timeInterval = NSDate().timeIntervalSinceDate(lastEventRefreshTime)
            if timeInterval >= 600 {
                AppStatus.EventStatus.tableShouldRefresh = true
            }
        }
        if let lastBulletinRefreshTime = AppStatus.BulletinStatus.lastRefreshTime {
            let timeInterval = NSDate().timeIntervalSinceDate(lastBulletinRefreshTime)
            if timeInterval >= 600 {
                AppStatus.BulletinStatus.tableShouldRefresh = true
            }
        }
        if let lastRendezvousRefreshTime = AppStatus.RendezvousStatus.lastRefreshTime {
            let timeInterval = NSDate().timeIntervalSinceDate(lastRendezvousRefreshTime)
            if timeInterval >= 600 {
                AppStatus.RendezvousStatus.tableShouldRefresh = true
            }
        }
    }
    static func displayAlertViewFromViewController(parentVC:UIViewController, message:String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(defaultAction)
        parentVC.presentViewController(alert, animated: true, completion: nil)
    }
}