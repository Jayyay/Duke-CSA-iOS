//
//  BasicPost.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class BasicPost: NSObject {
    let PFInstance:PFObject
    var author:PFUser!
    var mainPost:String!
    var postTime:NSDate!
    
    init?(parseObject:PFObject){
        PFInstance = parseObject
        super.init()
        
        //required
        if let a = parseObject[PFKey.ME.BUG_REPORT.AUTHOR] as? PFUser {
            author = a
        }else{
            return nil
        }
        if let m = parseObject[PFKey.ME.BUG_REPORT.MAIN_POST] as? String {
            mainPost = m
        }else{
            return nil
        }
        if let p = parseObject.createdAt {
            postTime = p
        }else{
            return nil
        }
    }
}
