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
   // @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var ctTagHeight: NSLayoutConstraint!
    
    var childEvent:Event!
    let colorComing = AppConstants.Color.cuteRed, colorOld = AppConstants.Color.DukeBlue
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTag.layer.cornerRadius = 5//label.frame.height * 0.5
        lblTag.layer.masksToBounds = true
    }
    
    func initWithEvent(evt:Event){
        childEvent = evt
        
        //title
        lblTitle.text = childEvent.title
        lblTitle.font = UIFont (name: "Papyrus", size: 20)
        
        //when
        lblWhen.text = "Time: \(AppTools.formatDateUserFriendly(childEvent.date))"
        
        //where
        lblWhere.text = "Location: \(childEvent.location)"
        
        lblPostTime.text = "Post time: \(AppTools.formatDateUserFriendly(childEvent.createdAt))"
        
        if evt.date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            lblTag.hidden = true
            ctTagHeight.constant = 0
        }else {
            /*let imgArr = [UIImage(named: "icon_slime"), UIImage(named: "icon_snail"),UIImage(named: "icon_eliza"),UIImage(named: "icon_pig")]
            imgCheck.image = imgArr[Int(arc4random_uniform(4))]*/
            lblTag.hidden = false
            ctTagHeight.constant = 15
        }
        layoutIfNeeded()
    }

}
