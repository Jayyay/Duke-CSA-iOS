//
//  BasicPostCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class BasicPostCell: UITableViewCell {

    @IBOutlet weak var lblAuthor: UserLabel!
    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var lblMainPost: UILabel!
    @IBOutlet weak var lblPostTime: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    weak var bugVC:MeReportBugTableViewController!
    var childPost:BasicPost!
    var curIndex:Int!
    
    @IBAction func onDelete(sender: AnyObject) {
        let str = "Delete this bug report?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { _ in
            self.childPost.PFInstance[PFKey.IS_VALID] = false
            self.childPost.PFInstance.saveInBackground()
            self.bugVC.postArr.removeAtIndex(self.curIndex)
            self.bugVC.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        bugVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgPropic.layer.cornerRadius = 20.0
        imgPropic.layer.masksToBounds = true
        btnDelete.hidden = true
    }

    func initWithPost(post:BasicPost, parentVC:MeReportBugTableViewController, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath) {
        bugVC = parentVC
        childPost = post
        curIndex = indexPath.row
        AppFunc.downloadPropicFromParse(user: post.author, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        lblAuthor.initLabel(author: post.author, fontSize: 15, fromVC: parentVC)
        lblMainPost.text = post.mainPost
        lblPostTime.text = AppTools.formatDateUserFriendly(post.postTime)
        self.btnDelete.hidden = (post.author.objectId != PFUser.currentUser()!.objectId)
        layoutIfNeeded()
    }
    
}
