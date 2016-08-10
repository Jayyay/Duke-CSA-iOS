//
//  QAPost.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/23/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation
import CoreText

enum ChangeVoteButton {
    case UpPlain
    case UpHighlight
    case DownPlain
    case DownHighlight
    case None
}

let systemFontLarge = UIFont.systemFontOfSize(15.0)
let systemFontSmall = UIFont.systemFontOfSize(14.0)

class QAPost: NSObject {
    var PFInstance: PFObject
    var type: String!
    var author: PFUser!
    var title: String! = ""
    var vote = 0
    var upvotes: [String] = []
    var downvotes: [String] = []
    var answers: [PFObject] = [] // answers to this post
    var question: AnyObject = NSNull()
    var postTime: NSDate!
    var replies: [PFObject] = []
    
    var voteSuccess: Bool!
    let TIME_OUT_IN_SEC = 2.0
    
    var content = NSMutableAttributedString(string: "", attributes: [NSFontAttributeName: systemFontSmall])
    
    init? (parseObject: PFObject) {
        PFInstance = parseObject
        super.init()
        
        if let t = parseObject[PFKey.QA.KIND] as? String {
            type = t
        } else {
            return nil
        }
        if let ttl = parseObject[PFKey.QA.TITLE] as? String {
            title = ttl
        }
        if let a = parseObject[PFKey.QA.AUTHOR] as? PFUser {
            author = a
        } else {
            return nil
        }
        if let m = parseObject[PFKey.QA.CONTENT] as? String {
            let data = m.dataUsingEncoding(NSUTF8StringEncoding)!
            let tryContent = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], documentAttributes: nil)
            if let success = tryContent {
                content = success
            }
            else {
                print("Error: QAPost content is not encoded in RTF format. Did anyone insert plain text data?")
            }
        } else {
            return nil
        }
        if let v = parseObject[PFKey.QA.VOTE] as? NSInteger {
            vote = v
        } else {
            return nil
        }
        if let p = parseObject.createdAt {
            postTime = p
        } else {
            return nil
        }
        if let ans = parseObject[PFKey.QA.ANSWERS] as? [PFObject] {
            answers = ans
        }
        if let up = parseObject[PFKey.QA.UPVOTES] as? [String] {
            self.upvotes = up
        }
        if let down = parseObject[PFKey.QA.DOWNVOTES] as? [String] {
            self.downvotes = down
        }
        if let question = parseObject[PFKey.QA.TOQUESTION] as? PFObject {
            self.question = question
        }
        if let reps = parseObject[PFKey.QA.REPLIES] as? [PFObject] {
            self.replies = reps
        }
    }
    
    init (type: String!) {
        PFInstance = PFObject(className: PFKey.QA.CLASSKEY)
        super.init()
        self.type = type
        self.author = PFUser.currentUser()
    }
    
    func saveWithBlock(block: (Bool, NSError?) -> Void) {
        PFInstance[PFKey.QA.KIND] = type;
        PFInstance[PFKey.QA.AUTHOR] = author;
        
        content.setAttributes([NSFontAttributeName: systemFontSmall], range: NSRange(location: 0, length: content.length))
        let contentData = try! content.dataFromRange(NSRange(location: 0, length: content.length), documentAttributes: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType])
        let rtfContent = NSString(data: contentData, encoding: NSUTF8StringEncoding)!
        PFInstance[PFKey.QA.CONTENT] = rtfContent;
        
        PFInstance[PFKey.QA.TITLE] = title;
        PFInstance[PFKey.QA.UPVOTES] = upvotes;
        PFInstance[PFKey.QA.DOWNVOTES] = downvotes;
        PFInstance[PFKey.QA.VOTE] = vote;
        PFInstance[PFKey.QA.TOQUESTION] = question;
        PFInstance[PFKey.QA.REPLIES] = replies;
        PFInstance.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            block(success, error)
        }
    }
    
    var upvote_flag = false
    
    func upvote(voteLabel: UILabel!, upvoteButton: UIButton!, downvoteButton: UIButton!, cell: UITableViewCell) {
        upvote_flag = false
        let id = PFUser.currentUser()!.objectId!
        print(self.upvotes)
        var action: ChangeVoteButton = .None
        let voteBefore = self.vote
        let upvotesBefore = self.upvotes
        let downvotesBefore = self.downvotes
        let upvoteImageBefore = upvoteButton.imageView?.image
        let downvoteImageBefore = downvoteButton.imageView?.image
        
        if (self.upvotes.contains(id)) {
            self.upvotes.removeAtIndex(self.upvotes.indexOf(id)!)
            self.vote -= 1
            action = .UpPlain
        }
        else if (self.downvotes.contains(id)) {
            self.downvotes.removeAtIndex(self.downvotes.indexOf(id)!)
            self.vote += 1
            action = .DownPlain
        }
        else {
            self.upvotes.append(id)
            self.vote += 1
            action = .UpHighlight
            upvote_flag = true
        }
        voteLabel.text = String(self.vote)
        
        switch action {
        case .UpPlain:
            upvoteButton.setImage(AppConstants.Vote.UPVOTE_PLAIN, forState: .Normal)
        case .DownPlain:
            downvoteButton.setImage(AppConstants.Vote.DOWNVOTE_PLAIN, forState: .Normal)
        case .UpHighlight:
            upvoteButton.setImage(AppConstants.Vote.UPVOTE_HIGHLIGHT, forState: .Normal)
        default:
            break
        }
        
        cell.setNeedsLayout()
        
        voteSuccess = false
        
        self.saveWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("Saving vote info error: \(error)")
                self.vote = voteBefore
                voteLabel.text = String(self.vote)
                self.upvotes = upvotesBefore
                self.downvotes = downvotesBefore
                upvoteButton.setImage(upvoteImageBefore, forState: .Normal)
                downvoteButton.setImage(downvoteImageBefore, forState: .Normal)
            }
            else {
                self.voteSuccess = true
                if (self.upvote_flag) { self.notifyAuthorUpvote() }
            }
        }
    }
    
    func downvote(voteLabel: UILabel!, upvoteButton: UIButton!, downvoteButton: UIButton!, cell: UITableViewCell) {
        let id = PFUser.currentUser()!.objectId!
        var action: ChangeVoteButton = .None
        let voteBefore = self.vote
        let upvotesBefore = self.upvotes
        let downvotesBefore = self.downvotes
        let upvoteImageBefore = upvoteButton.imageView?.image
        let downvoteImageBefore = downvoteButton.imageView?.image
        
        if (self.downvotes.contains(id)) {
            self.downvotes.removeAtIndex(self.downvotes.indexOf(id)!)
            self.vote += 1
            action = .DownPlain
        }
        else if (self.upvotes.contains(id)) {
            self.upvotes.removeAtIndex(self.upvotes.indexOf(id)!)
            self.vote -= 1
            action = .UpPlain
        }
        else {
            self.downvotes.append(id)
            self.vote -= 1
            action = .DownHighlight
        }
        voteLabel.text = String(self.vote)
        
        switch action {
        case .DownPlain:
            downvoteButton.setImage(AppConstants.Vote.DOWNVOTE_PLAIN, forState: .Normal)
        case .UpPlain:
            upvoteButton.setImage(AppConstants.Vote.UPVOTE_PLAIN, forState: .Normal)
        case .DownHighlight:
            downvoteButton.setImage(AppConstants.Vote.DOWNVOTE_HIGHLIGHT, forState: .Normal)
        default:
            break
        }
        
        cell.setNeedsLayout()
        
        voteSuccess = false
        
        self.saveWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("Saving vote info error: \(error)")
                self.vote = voteBefore
                voteLabel.text = String(self.vote)
                self.upvotes = upvotesBefore
                self.downvotes = downvotesBefore
                upvoteButton.setImage(upvoteImageBefore, forState: .Normal)
                downvoteButton.setImage(downvoteImageBefore, forState: .Normal)
            }
            else {
                self.voteSuccess = true
            }
        }
    }
    
    func notifyAuthorUpvote() {
        var pushID = "", pushType = "", message = ""
        let currentUserName = PFUser.currentUser()![PFKey.USER.DISPLAY_NAME]
        if (type == PFKey.QA.TYPE.QUESTION) {
            pushID = PFInstance.objectId!
            pushType = AppNotif.NotifType.NEW_QA_VOTE_QUESTION
            message = "\(currentUserName) upvoted your question: \(title.truncate(20))"
        }
        else if (type == PFKey.QA.TYPE.ANSWER) {
            pushID = question.objectId!! + ":" + PFInstance.objectId!
            pushType = AppNotif.NotifType.NEW_QA_VOTE_ANSWER
            message = "\(currentUserName) upvoted your answer: \(content.string.truncate(20))"
        }
        AppNotif.pushNotification(forType: pushType, withMessage: message, toUser: author, withSoundName: AppConstants.SoundFile.NOTIF_1, PFInstanceID: pushID)
    }
}
