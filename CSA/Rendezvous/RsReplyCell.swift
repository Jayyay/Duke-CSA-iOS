//
//  RsReplyCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class RsReplyCell: UITableViewCell {
    
    @IBOutlet weak var lblReply: UserLabel!
    @IBOutlet weak var lblPostTime: UILabel!
    
    
    var childReply:RsReply!
    weak var parentVC:RsReplyViewController!
    var highLightedRange:NSRange = NSMakeRange(NSNotFound, 0)
    
    var authorNameRange:NSRange = NSMakeRange(NSNotFound, 0)
    var replyToNameRange:NSRange = NSMakeRange(NSNotFound, 0)
    
    func initWithReply(rply:RsReply, fromVC:RsReplyViewController){
        childReply = rply
        parentVC = fromVC
        lblReply.initLabel(author: childReply.author, replyToUser: childReply.replyTo, withPost: childReply.mainPost, fromVC: parentVC)
        lblPostTime.text = AppTools.formatDateUserFriendly(childReply.createdAt)
        layoutIfNeeded()
    }

}
