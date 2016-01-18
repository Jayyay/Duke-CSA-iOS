//
//  EventTitleCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 11/4/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventTitleCell: UITableViewCell {

    @IBOutlet weak var lblWhen: UILabel!
    @IBOutlet weak var lblWhere: UILabel!
    
    func initWithEvent(event:Event) {
        //when
        if let d = event.date {
            lblWhen.text = "Time: \(AppTools.formatDateWithWeekDay(d))"
        }else {
            lblWhen.text = "Time: N/A"
        }
        
        //where
        if let l = event.location {
            lblWhere.text = "Location: \(l)"
        }else {
            lblWhere.text = "Location: N/A"
        }
    }

}
