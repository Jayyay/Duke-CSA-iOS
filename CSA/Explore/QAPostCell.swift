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
    @IBOutlet weak var voteBackground: UIView!
    
    weak var parentVC: UIViewController!
    var childQA: QAPost!
    
    let TIME_OUT_IN_SEC = 2.0
    
    @IBOutlet weak var dot: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnBackground))
        voteBackground.addGestureRecognizer(tap)
        voteBackground.backgroundColor = UIColor.clearColor()

        dot.hidden = true
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
        
        if let _ = self.parentVC as? QAViewController {
            mainPostLabel.attributedText = post.content
        }
        else if post.type == PFKey.QA.TYPE.QUESTION {
            let mainPostString = NSMutableAttributedString(attributedString: post.content)
            mainPostString.setAttributes([NSFontAttributeName: systemFontLarge], range: NSRange(location: 0, length: mainPostString.length))
            mainPostLabel.attributedText = (mainPostString as NSAttributedString)
        }
        else {
            mainPostLabel.attributedText = post.content
        }
            
        voteLabel.text = String(post.vote)
        
        //optional
        if post.title != "" {
            postTitle.hidden = false
        } else {
            postTitle.hidden = true
        }
        
        // cannot vote when only viewing part of the questions
        if let _ = self.parentVC as? QAViewController {
            upvoteButton.hidden = true
            downVoteButton.hidden = true
        }
        
        // init vote buttons
        let id = PFUser.currentUser()!.objectId!
        if post.upvotes.contains(id) {
            upvoteButton.setImage(AppConstants.Vote.UPVOTE_HIGHLIGHT, forState: .Normal)
        }
        if post.downvotes.contains(id) {
            downVoteButton.setImage(AppConstants.Vote.DOWNVOTE_HIGHLIGHT, forState: .Normal)
        }
        
        // red dot indicating notif
        if let notif = AppData.NotifData.notifInfo {
            if (notif.questions.contains(post.PFInstance.objectId!)
                || notif.answers.contains(post.PFInstance.objectId!)
                || notif.ansQuestions.contains(post.PFInstance.objectId!)) {
                dot.backgroundColor = UIColor.redColor()
                dot.hidden = false
                print("dot")
            } else {
                dot.hidden = true
            }
        }
        
        setNeedsLayout()
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
    
    func tapOnBackground() {
        print("tapping on background")
    }
}
