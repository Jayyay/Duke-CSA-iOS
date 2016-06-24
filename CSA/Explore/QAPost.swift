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
    var content: String! = ""
    var postTime: NSDate!
    
    init? (parseObject: PFObject) {
        PFInstance = parseObject
        super.init()
        
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
        PFInstance.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            block(success, error)
        }
    }
}