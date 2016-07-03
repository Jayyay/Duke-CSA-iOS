//
//  QAAnswerCell.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/27/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAAnswerCell: UITableViewCell {
    
    @IBOutlet weak var authorLabel: UserLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var mainPostLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var propicImageView: UIImageView!
    
    weak var parentVC: UIViewController!
    var childQA: QAPost!
    
    let TIME_OUT_IN_SEC = 2.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        propicImageView.layer.cornerRadius = propicImageView.frame.height * 0.5
        propicImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithPost(post: QAPost, fromVC: UIViewController, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath) {
        childQA = post
        self.parentVC = fromVC
        
        AppFunc.downloadPropicFromParse(user: childQA.author, saveToImgView: propicImageView, inTableView: tableView, forIndexPath: indexPath)
        
        //required
        authorLabel.initLabel(author: post.author, fontSize: 17, fromVC: parentVC)
        timeLabel.text = AppTools.formatDateUserFriendly(post.postTime)
        mainPostLabel.attributedText = post.content
        voteLabel.text = String(post.vote)
        
        // init vote buttons
        let id = PFUser.currentUser()!.objectId!
        if post.upvotes.contains(id) {
            upvoteButton.setImage(AppConstants.Vote.UPVOTE_HIGHLIGHT, forState: .Normal)
        }
        if post.downvotes.contains(id) {
            downVoteButton.setImage(AppConstants.Vote.DOWNVOTE_HIGHLIGHT, forState: .Normal)
        }
        
        layoutIfNeeded()
    }

    @IBAction func upvote(sender: AnyObject) {
        NSTimer.scheduledTimerWithTimeInterval(TIME_OUT_IN_SEC, target: self, selector: #selector(voteTimeOut), userInfo: nil, repeats: false)
        self.childQA.upvote(voteLabel, upvoteButton: upvoteButton, downvoteButton: downVoteButton, cell: self)
    }
    
    @IBAction func downvote(sender: AnyObject) {
        NSTimer.scheduledTimerWithTimeInterval(TIME_OUT_IN_SEC, target: self, selector: #selector(voteTimeOut), userInfo: nil, repeats: false)
        self.childQA.downvote(voteLabel, upvoteButton: upvoteButton, downvoteButton: downVoteButton, cell: self)
    }
    
    func voteTimeOut() {
        if (!self.childQA.voteSuccess) {
            parentVC.view.hideToastActivity()
            parentVC.view.makeToast(message: "Connecting timed out, your vote FAILED.", duration: 1.0, position: HRToastPositionCenterAbove)
        }
    }
}
