//
//  QAPost.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/23/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation

class QAPost: NSObject {
    var PFInstance: PFObject
    var type: String!
    var author: PFUser!
    var title: String! = ""
    var content: String! = ""
    var vote = 0
    var upvotes: [String] = []
    var downvotes: [String] = []
    var answers: [PFObject] = [] // answers to this post
    var question: AnyObject = NSNull()
    var postTime: NSDate!
    var replies: [PFObject] = []
    
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
            content = m
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
        PFInstance[PFKey.QA.CONTENT] = content;
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
    
    func upvote(voteLabel: UILabel!) {
        let id = PFUser.currentUser()!.objectId!
        print(self.upvotes)
        if (self.upvotes.contains(id)) {
            self.upvotes.removeAtIndex(self.upvotes.indexOf(id)!)
            self.vote -= 1
        }
        else if (self.downvotes.contains(id)) {
            self.downvotes.removeAtIndex(self.downvotes.indexOf(id)!)
            self.vote += 1
        }
        else {
            self.upvotes.append(id)
            self.vote += 1
        }
        self.saveWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("Saving vote info error: \(error)")
            }
            else {
                voteLabel.text = String(self.vote)
            }
        }
    }
    
    func downvote(voteLabel: UILabel!) {
        let id = PFUser.currentUser()!.objectId!
        if (self.downvotes.contains(id)) {
            self.downvotes.removeAtIndex(self.downvotes.indexOf(id)!)
            self.vote += 1
        }
        else if (self.upvotes.contains(id)) {
            self.upvotes.removeAtIndex(self.upvotes.indexOf(id)!)
            self.vote -= 1
        }
        else {
            self.downvotes.append(id)
            self.vote -= 1
        }
        self.saveWithBlock { (success: Bool, error: NSError?) in
            if let error = error {
                print("Saving vote info error: \(error)")
            }
            else {
                voteLabel.text = String(self.vote)
            }
        }
    }
}