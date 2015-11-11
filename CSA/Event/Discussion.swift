//
//  Discussion.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/20/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class Discussion: NSObject {
    let PFInstance:PFObject
    var parent:PFObject!
    var author:PFUser!
    var mainPost:String!
    var likes:[PFUser] = []
    var replies:[Reply] = []
    var postTime:NSDate!
    //derived
    var IdidLike = false
    
    
    init?(parseObject:PFObject){
        PFInstance = parseObject
        super.init()
        
        //required
        if let p = parseObject[PFKey.EVENT.DIS.PARENT] as? PFObject {
            parent = p
        }else{
            return nil
        }
        if let a = parseObject[PFKey.EVENT.DIS.AUTHOR] as? PFUser {
            author = a
        }else{
            return nil
        }
        if let m = parseObject[PFKey.EVENT.DIS.MAIN_POST] as? String {
            mainPost = m
        }else{
            return nil
        }
        if let p = parseObject.createdAt {
            postTime = p
        }else{
            return nil
        }
        
        //likes
        let id = PFUser.currentUser()!.objectId
        if let arr = parseObject[PFKey.EVENT.DIS.LIKES] as? [PFUser] {
            for u in arr {
                likes.append(u)
                if u.objectId == id {
                    IdidLike = true
                }
            }
        }
        
        //store replies
        if let arr = parseObject[PFKey.EVENT.DIS.REPLIES] as? [PFObject] {
            for rep in arr {
                if !(rep[PFKey.IS_VALID] as! Bool){ //not valid (user deletion, or Parse end change)
                    continue
                }
                if let newRep = Reply(parseObject: rep, parentDis: self){
                    replies.append(newRep)
                }
            }
        }
    }
}
