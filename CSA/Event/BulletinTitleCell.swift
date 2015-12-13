//
//  BulletinTitleCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 12/5/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

class BulletinTitleCell: UITableViewCell {
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    
    @IBOutlet weak var ctSubtitleHeight: NSLayoutConstraint!
    @IBOutlet weak var ctWhenHeight: NSLayoutConstraint!
    @IBOutlet weak var ctWhereHeight: NSLayoutConstraint!
    @IBOutlet weak var ctSubtitleTop: NSLayoutConstraint!
    @IBOutlet weak var ctWhenTop: NSLayoutConstraint!
    @IBOutlet weak var ctWhereTop: NSLayoutConstraint!
    
    func initWithBulletin(bul:Bulletin) {
        if let subtitle = bul.subtitle {
            ctSubtitleTop.constant = 2
            ctSubtitleHeight.constant = 20
            lblSubtitle.hidden = false
            lblSubtitle.text = subtitle
        }else{
            ctSubtitleTop.constant = 0
            ctSubtitleHeight.constant = 0
            lblSubtitle.hidden = true
        }
        if let date = bul.date{
            ctWhenTop.constant = 2
            ctWhenHeight.constant = 20
            lblWhen.hidden = false
            lblWhen.text = AppTools.formatDateWithWeekDay(date)
        }else{
            ctWhenTop.constant = 0
            ctWhenHeight.constant = 0
            lblWhen.hidden = true
        }
        if let location = bul.location {
            ctWhereTop.constant = 2
            ctWhereHeight.constant = 20
            lblWhere.hidden = false
            lblWhere.text = location
        }else{
            ctWhereTop.constant = 0
            ctWhereHeight.constant = 0
            lblWhere.hidden = true
        }
    }
}
