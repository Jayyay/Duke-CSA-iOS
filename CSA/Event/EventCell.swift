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
    @IBOutlet weak var imgCheck: UIImageView!
    
    var childEvent:Event!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.layer.cornerRadius = 10.0
        viewContainer.layer.masksToBounds = true
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
            imgCheck.image = UIImage(named: "icon_check")
        }else {
            let imgArr = [UIImage(named: "icon_slime"), UIImage(named: "icon_snail"),UIImage(named: "icon_eliza"),UIImage(named: "icon_pig")]
            imgCheck.image = imgArr[Int(arc4random_uniform(4))]
        }
        layoutIfNeeded()
    }

}
