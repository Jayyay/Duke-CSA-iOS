//
//  BulletinCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/14/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class BulletinCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblPostTime: UILabel!
    
    
    @IBOutlet weak var ctSubtitleTop: NSLayoutConstraint!
    
    @IBOutlet weak var ctSubtitleHeight: NSLayoutConstraint!
    @IBOutlet weak var ctWhenTop: NSLayoutConstraint!
    @IBOutlet weak var ctWhenHeight: NSLayoutConstraint!
    @IBOutlet weak var ctWhereTop: NSLayoutConstraint!
    @IBOutlet weak var ctWhereHeight: NSLayoutConstraint!
    
    var childBulletin:Bulletin!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.layer.cornerRadius = 10.0
        viewContainer.layer.masksToBounds = true
    }
    
    func initWithBulletin(bln:Bulletin){
        childBulletin = bln
        //required field
        lblTitle.text = childBulletin.title
        
        //optional
        if let subtitle = childBulletin.subtitle {
            ctSubtitleTop.constant = 8
            ctSubtitleHeight.constant = 22
            lblSubtitle.hidden = false
            lblSubtitle.text = subtitle
        }else{
            ctSubtitleTop.constant = 0
            ctSubtitleHeight.constant = 0
            lblSubtitle.hidden = true
        }
        if let date = childBulletin.date{
            ctWhenTop.constant = 8
            ctWhenHeight.constant = 20
            lblWhen.hidden = false
            lblWhen.text = "Time: \(AppTools.formatDateUserFriendly(date))"
        }else{
            ctWhenTop.constant = 0
            ctWhenHeight.constant = 0
            lblWhen.hidden = true
        }
        if let location = childBulletin.location {
            ctWhereTop.constant = 8
            ctWhereHeight.constant = 20
            lblWhere.hidden = false
            lblWhere.text = "Location: \(location)"
        }else{
            ctWhereTop.constant = 0
            ctWhereHeight.constant = 0
            lblWhere.hidden = true
        }
        lblPostTime.text = "Post time: \(AppTools.formatDateUserFriendly(childBulletin.createdAt))"
        layoutIfNeeded()
    }
}
