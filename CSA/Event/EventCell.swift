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
        
        //when
        lblWhen.text = "When: \(AppTools.formatDateUserFriendly(childEvent.date))"
        
        //where
        lblWhere.text = "Where: \(childEvent.location)"
        
        lblPostTime.text = AppTools.formatDateUserFriendly(childEvent.createdAt)
        
        layoutIfNeeded()
    }

}
