//
//  EventCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/7/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblPostTime: UILabel!
    @IBOutlet weak var dot: UIView!
   // @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var ctTagHeight: NSLayoutConstraint!
    @IBOutlet weak var ctProfileBottom: NSLayoutConstraint!
    @IBOutlet weak var ctProfileHeight: NSLayoutConstraint!

    var childEvent:Event!
    let colorComing = AppConstants.Color.cuteRed, colorOld = AppConstants.Color.DukeBlue
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTag.layer.cornerRadius = 5//label.frame.height * 0.5
        lblTag.layer.masksToBounds = true
    }
    
    func initWithEvent(evt:Event, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath){
        childEvent = evt
        
        //title
        lblTitle.text = childEvent.title
        
        //when
        lblTag.hidden = true
        ctTagHeight.constant = 0
        if let d = childEvent.date {
            lblWhen.text = "Time: \(AppTools.formatDateUserFriendly(d))"
            if d.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                lblTag.hidden = false
                ctTagHeight.constant = 15
            }
        } else {
            lblWhen.text = "Time: N/A"
        }
        
        //where
        if let l = childEvent.location {
            lblWhere.text = "Location: \(l)"
        }else {
            lblWhere.text = "Location: N/A"
        }
        
        lblPostTime.text = "Post time: \(AppTools.formatDateUserFriendly(childEvent.createdAt))"
        
        if let p = evt.propic {
            imgProfile.hidden = false
            ctProfileHeight.constant = 185
            ctProfileHeight.priority = 999
            AppFunc.downloadPictureFile(file: p, saveToImgView: imgProfile, inTableView: tableView, forIndexPath: indexPath)
        } else {
            imgProfile.hidden = true
            ctProfileHeight.constant = 0
            ctProfileHeight.priority = 999
        }
        
        // red dot indicating notif
        if let notif = AppData.NotifData.notifInfo {
            if (notif.events.contains(evt.PFInstance.objectId!)) {
                dot.backgroundColor = UIColor.redColor()
                dot.hidden = false
                print("dot")
            } else {
                dot.hidden = true
            }
        }
        
        layoutIfNeeded()
    }

}
