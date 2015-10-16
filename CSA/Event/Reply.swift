//
//  Reply.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/20/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class Reply: NSObject {
    //required
    let PFInstance:PFObject
    var parent:Discussion
    var author:PFUser!
    var mainPost:String!
    
    //optional
    var replyTo:PFUser?
    
    init?(parseObject:PFObject, parentDis:Discussion){
        PFInstance = parseObject
        parent = parentDis
        super.init()
        
        if let a = parseObject[PFKey.EVENT.DIS.RE.AUTHOR] as? PFUser {
            author = a
        }else{
            return nil
        }
        
        if let m = parseObject[PFKey.EVENT.DIS.RE.MAIN_POST] as? String {
            mainPost = m
        }else{
            return nil
        }
        
        replyTo = parseObject[PFKey.EVENT.DIS.RE.REPLY_TO] as? PFUser
    }
}
