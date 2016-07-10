//
//  Rendezvous.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/23/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class Rendezvous:NSObject {
    
    //required
    let PFInstance:PFObject
    var author:PFUser!
    var tags:[String] = []
    var mainPost:String!
    var postTime:NSDate!
    
    //optional
    var whenWhere:String?
    var title:String?
    //var date:String?
    //var location:String?
    
    //derived info
    var IdidGo = false
    var IdidLike = false
    var goings: [PFUser] = []
    var likes: [PFUser] = []
    var countGoings = 0
    var countLikes = 0
    var countReplies = 0
    
    init?(parseObject:PFObject){
        PFInstance = parseObject
        super.init()
        
        //required. If not valid, a failure will be triggered and nil returned.
        if let a = parseObject[PFKey.RENDEZVOUS.AUTHOR] as? PFUser {
            author = a
        }else{
            return nil
        }
        if let m = parseObject[PFKey.RENDEZVOUS.MAIN_POST] as? String {
            mainPost = m
        }else{
            return nil
        }
        if let c = parseObject.createdAt {
            postTime = c
        }else{
            return nil
        }
        
        //optional
        title = parseObject[PFKey.RENDEZVOUS.TITLE] as? String
        whenWhere = parseObject[PFKey.RENDEZVOUS.WHEN_WHERE] as? String
        
        //tags 
        /*
        if let tagArr = parseObject[PFKey.RENDEZVOUS.TAGS] as? [String] {
            for tag in tagArr {
                tags.append(tag)
            }
        }
        if tags.count == 0 {
            tags.append(RsTag.other)
        }*/
        if let tagArr = parseObject[PFKey.RENDEZVOUS.TAGS] as? [String] {
            tags = tagArr
        }
        if tags.count == 0 {
            return nil
        }
        
        //goings
        if let goArr = parseObject[PFKey.RENDEZVOUS.GOINGS] as? [PFUser] {
            goings = goArr
            countGoings = goings.count
            IdidGo = false
            for go in goArr {
                if go.objectId! == PFUser.currentUser()!.objectId! {
                    IdidGo = true
                    break
                }
            }
        }
        
        //likes
        if let likeArr = parseObject[PFKey.RENDEZVOUS.LIKES] as? [PFUser] {
            likes = likeArr
            countLikes = likes.count
            IdidLike = false
            for like in likeArr {
                if like.objectId! == PFUser.currentUser()!.objectId! {
                    IdidLike = true
                }
            }
        }
        
        //replies
        if let replyArr = parseObject[PFKey.RENDEZVOUS.REPLIES] as? [PFObject] {
            countReplies = replyArr.count
        }
    }
    
    func saveWithBlock(block: (Bool, NSError?) -> Void) {
        PFInstance[PFKey.RENDEZVOUS.LIKES] = likes
        PFInstance[PFKey.RENDEZVOUS.GOINGS] = goings
        PFInstance.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            block(success, error)
        }
    }
}
