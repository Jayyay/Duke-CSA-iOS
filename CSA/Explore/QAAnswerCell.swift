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
        mainPostLabel.text = post.content
        voteLabel.text = String(post.vote)
    }

    @IBAction func upvote(sender: AnyObject) {
        self.childQA.upvote(voteLabel)
    }
    
    @IBAction func downvote(sender: AnyObject) {
        self.childQA.downvote(voteLabel)
    }
}
