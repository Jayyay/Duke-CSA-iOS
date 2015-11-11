//
//  EventDetailMainCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 11/4/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventDetailMainCell: UITableViewCell {

    @IBOutlet weak var tvMainPost: UITextView!
    
    func initWithEvent(event:Event) {
        tvMainPost.text = event.detail
        layoutIfNeeded()
    }
    
}
