//
//  RsMenuTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class RsMenuTableViewController: UITableViewController {
    var sourceNavigationController : ENSideMenuProtocol!
    let vcNames:[String] = ["Comments","Goings","Likes"]
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
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("RS_MENU_CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "RS_MENU_CELL")
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
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == AppStatus.RendezvousStatus.currentlyDisplayedView.rawValue) {
            print("select same row, nothing happens")
            return
        }
        
        if indexPath.row == 0 {//choose to go to main view, just pop
            sourceNavigationController.popToMainView()
            return
        }
        
        //if current view is main view (index 0, aka rendezvous reply view), we directly push new view without pop
        let shouldPopOnce = (AppStatus.RendezvousStatus.currentlyDisplayedView != AppStatus.RendezvousStatus.ViewName.Reply)
        
        //need to present new view controller, remember to check vcNames[] for corresponding vc order
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController : UIViewController?
        
        switch (indexPath.row) {
            //case signupVC
        case 1:
            if AppData.RendezvousData.goingVC != nil {
                destViewController = AppData.RendezvousData.goingVC
            }else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardID.RENDEZVOUS.GOING)
            }
            break
            //case discussVC
        case 2:
            if AppData.RendezvousData.likeVC != nil {
                destViewController = AppData.RendezvousData.likeVC
            }else{
                destViewController = mainStoryboard.instantiateViewControllerWithIdentifier(StoryboardID.RENDEZVOUS.LIKE)
            }
            break
        default:
            break
        }
        if destViewController != nil{
            sourceNavigationController.setContentViewController(destViewController, shouldPopOnce: shouldPopOnce)
        }
    }

}
