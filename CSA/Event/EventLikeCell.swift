//
//  EventLikeCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/16/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventLikeCell: UITableViewCell {

    
    weak var parentVC:EventDiscussViewController!
    
    @IBOutlet weak var lblLikes: LikesLabel!
    @IBOutlet weak var viewSeparator: UIView!
    
    var authorNameRange = NSMakeRange(NSNotFound, 0)
    var highLightedRange = NSMakeRange(NSNotFound, 0)
    
    func initWithLikeArray(likes:[PFUser], fromVC:EventDiscussViewController) {
        parentVC = fromVC
        lblLikes.initLabel(likes: likes, fromVC: fromVC)
    }

}
