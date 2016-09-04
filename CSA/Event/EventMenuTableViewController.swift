//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class EventMenuTableViewController: UITableViewController {
    var sourceNavigationController : ENSideMenuProtocol!
    let vcNames:[String] = ["Details","More","Discussions","→"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return vcNames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("EVENT_MENU_CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "EVENT_MENU_CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = vcNames[indexPath.row]
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < 3{
            return 50
        }else{
            return 30
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.row == AppStatus.EventStatus.currentlyDisplayedView.rawValue) {
            print("select same row, nothing happens")
            return
        }
        
        //if current view is main view (index 0, aka event detail view), we directly push new view without pop
        let shouldPopOnce = (AppStatus.EventStatus.currentlyDisplayedView != AppStatus.EventStatus.ViewName.Detail)
        
        if indexPath.row == 0 {//choose to go to main view, just pop
            sourceNavigationController.popToMainView()
            return
        }
        
        if indexPath.row == 3 {//right arrow chosen, simply close the side menu
            sourceNavigationController.sideMenu?.hideSideMenu()
            return
        }
        
        //need to present new view controller, remember to check vcNames[] for corresponding vc order
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController : UIViewController?
        
        switch (indexPath.row) {
        //case signupVC
        case 1:
            if AppData.EventData.signupVC != nil {
                destViewController = AppData.EventData.signupVC
            }else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardID.EVENT.SIGN_UP)
            }
            break
        //case discussVC
        case 2:
            if AppData.EventData.discussVC != nil {
                destViewController = AppData.EventData.discussVC
            }else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardID.EVENT.DISCUSSION)
            }
            break
        default:
            break
        }
        if destViewController != nil{
            sourceNavigationController.setContentViewController(destViewController, shouldPopOnce: shouldPopOnce)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
