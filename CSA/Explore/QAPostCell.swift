//
//  QAPostCell.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/24/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAPostCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UserLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var mainPostLabel: UILabel!
    @IBOutlet weak var mainPostTop: NSLayoutConstraint!
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    weak var parentVC: UIViewController!
    var childQA: QAPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithPost(post: QAPost, fromVC: UIViewController, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath) {
        childQA = post
        self.parentVC = fromVC
        
        //required
        authorLabel.initLabel(author: post.author, fontSize: 17, fromVC: parentVC)
        timeLabel.text = AppTools.formatDateUserFriendly(post.postTime)
        if let ttl = post.title {
            postTitle.text = ttl
        }
        
        mainPostLabel.text = post.content
        voteLabel.text = String(post.vote)
        
        //optional
        if let _ = post.title {
            mainPostTop.constant = 34
            postTitle.hidden = false
        } else {
            mainPostTop.constant = 10
            postTitle.hidden = true
        }
        
        // cannot vote when only viewing part of the questions
        if let _ = self.parentVC as? QAViewController {
            upvoteButton.hidden = true
            downVoteButton.hidden = true
        }
//        if let ww = post.whenWhere {
//            ctRsWhenHeight.constant = 22
//            ctRsWhenTop.constant = 2
//            lblRsWhenWhere.hidden = false
//            lblRsWhenWhere.text = ww
//        }else{
//            ctRsWhenHeight.constant = 0
//            ctRsWhenTop.constant = 0
//            lblRsWhenWhere.hidden = true
//        }
        
        layoutIfNeeded()
    }
    
    @IBAction func upvote(sender: AnyObject) {
        self.childQA.upvote(voteLabel, upvoteButton: upvoteButton, downvoteButton: downVoteButton, cell: self)
        print(upvoteButton.imageView?.image)
        self.setNeedsLayout()
    }
    
    @IBAction func downvote(sender: AnyObject) {
        self.childQA.downvote(voteLabel, upvoteButton: upvoteButton, downvoteButton: downVoteButton, cell: self)
        self.setNeedsLayout()
    }
}
