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
    var title: String?
    var content: String! = ""
    var vote: NSInteger! = 0
    var upvotes: [PFUser]?
    var downvotes: [PFUser]?
    var answers: [PFObject]? // answers to this post
    var question: [PFObject]? // this post is an answer, points to the question
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
    }
    
    init? (type: String!) {
        PFInstance = PFObject(className: PFKey.QA.CLASSKEY)
        super.init()
        self.type = type
        if let user = PFUser.currentUser() {
            self.author = user
        }
        else {
            print("user not logged in for some weird reason")
            return nil
        }
    }
    
    func saveWithBlock(block: (Bool, NSError?) -> Void) {
        PFInstance[PFKey.QA.AUTHOR] = author;
        PFInstance[PFKey.QA.CONTENT] = content;
        PFInstance[PFKey.QA.TITLE] = title;
        PFInstance[PFKey.QA.UPVOTES] = upvotes;
        PFInstance[PFKey.QA.DOWNVOTES] = downvotes;
        PFInstance[PFKey.QA.VOTE] = vote;
        PFInstance.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            block(success, error)
        }
    }
}