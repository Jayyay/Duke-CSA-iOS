//
//  RsReply.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/23/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class RsReply: NSObject {
    var PFInstance:PFObject
    var parent:Rendezvous
    var author:PFUser!
    var mainPost:String!
    var createdAt:NSDate!
    
    //var isSubReply:Bool = false
    var replyTo:PFUser?
    
    init?(parseObject:PFObject, parentRs:Rendezvous) {
        PFInstance = parseObject
        parent = parentRs
        super.init()
        
        //required
        if let a = parseObject[PFKey.RENDEZVOUS.RE.AUTHOR] as? PFUser {
            author = a
        }else {
            return nil
        }
        if let m = parseObject[PFKey.RENDEZVOUS.RE.MAIN_POST] as? String {
            mainPost = m
        }else {
            return nil
        }
        if let c = parseObject.createdAt {
            createdAt = c
        }else{
            return nil
        }
        
        //optional
        replyTo = parseObject[PFKey.RENDEZVOUS.RE.REPLY_TO] as? PFUser
    }
}
