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
    var upvotes: [PFUser] = []
    var downvotes: [PFUser] = []
    var answers: [PFObject] = [] // answers to this post
    var question: AnyObject = NSNull()
    var postTime: NSDate!
    
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
        if let up = parseObject[PFKey.QA.UPVOTES] as? [PFUser] {
            self.upvotes = up
        }
        if let down = parseObject[PFKey.QA.DOWNVOTES] as? [PFUser] {
            self.downvotes = down
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
        PFInstance.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            block(success, error)
        }
    }
    
    
}