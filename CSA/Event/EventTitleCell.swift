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
        lblWhen.text = "Time: \(AppTools.formatDateWithWeekDay(event.date))"
        lblWhere.text = "Location: \(event.location)"
    }

}
