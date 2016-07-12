//
//  QAReplyCell.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/27/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAReplyCell: UITableViewCell {
    
    @IBOutlet weak var lblReply: UserLabel!
    @IBOutlet weak var lblPostTime: UILabel!
    
    var childReply: QAReply!
    weak var parentVC: QAAnswerViewController!
    var highLightedRange: NSRange = NSMakeRange(NSNotFound, 0)
    
    var authorNameRange: NSRange = NSMakeRange(NSNotFound, 0)
    var replyToNameRange: NSRange = NSMakeRange(NSNotFound, 0)
    
    func initWithReply(rply: QAReply, fromVC: QAAnswerViewController) {
        childReply = rply
        parentVC = fromVC
        lblReply.initLabel(author: childReply.author, replyToUser: childReply.replyTo, withPost: childReply.mainPost, fromVC: parentVC)
        lblPostTime.text = AppTools.formatDateUserFriendly(childReply.createdAt)
        layoutIfNeeded()
    }
}
