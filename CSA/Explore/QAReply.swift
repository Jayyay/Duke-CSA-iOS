//
//  QAReply.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/27/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

class QAReply: NSObject {
    var PFInstance: PFObject
    var parent: QAPost
    var author: PFUser!
    var mainPost: String!
    var createdAt: NSDate!
    
    //var isSubReply:Bool = false
    var replyTo: PFUser?
    
    init? (parseObject: PFObject, parentQA: QAPost) {
        PFInstance = parseObject
        parent = parentQA
        super.init()
        
        //required
        if let a = parseObject[PFKey.QA.RE.AUTHOR] as? PFUser {
            author = a
        } else {
            return nil
        }
        if let m = parseObject[PFKey.QA.RE.MAIN_POST] as? String {
            mainPost = m
        } else {
            return nil
        }
        if let c = parseObject.createdAt {
            createdAt = c
        } else {
            return nil
        }
        
        //optional
        replyTo = parseObject[PFKey.QA.RE.REPLY_TO] as? PFUser
    }
}
