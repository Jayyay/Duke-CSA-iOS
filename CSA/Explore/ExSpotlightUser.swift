//
//  ExSpotlightUser.swift
//  Duke CSA
//
//  Created by Zhe Wang on 8/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExSpotlightUser: NSObject {
    var PFInstance:PFObject
    
    var contact:ExContact!
    var isOn:Bool = true
    var bonus:Int = 0
    var scores: Int = 0
    var points: Int = 0
    
    var IdidLike:Bool = false
    var IdidVote0:Bool = false
    var IdidVote1:Bool = false
    var IdidVote2:Bool = false
    
    init?(parseObject:PFObject){
        PFInstance = parseObject
        super.init()
        
        var countLikes: Int = 0
        var countVote0: Int = 0
        var countVote1: Int = 0
        var countVote2: Int = 0
        //required
        if let a = parseObject[PFKey.SPOTLIGHT.USER] as? PFUser {
            if let c = ExContact(user: a) {
                contact = c
            }else {
                return nil
            }
        }else {
            return nil
        }
        
        if let i = parseObject[PFKey.SPOTLIGHT.IS_ON] as? Bool {
            isOn = i
        }else {
            return nil
        }
        
        if let likeArr = parseObject[PFKey.SPOTLIGHT.LIKES] as? [PFUser] {
            countLikes = likeArr.count
            for u in likeArr {
                if u.objectId == PFUser.currentUser()?.objectId {
                    IdidLike = true
                    break
                }
            }
        }else {
            return nil
        }
        
        if let vote0Arr = parseObject[PFKey.SPOTLIGHT.VOTE0] as? [PFUser] {
            countVote0 = vote0Arr.count
            for u in vote0Arr {
                if u.objectId == PFUser.currentUser()?.objectId {
                    IdidVote0 = true
                    break
                }
            }
        }else {
            return nil
        }
        
        if let vote1Arr = parseObject[PFKey.SPOTLIGHT.VOTE1] as? [PFUser] {
            countVote1 = vote1Arr.count
            for u in vote1Arr {
                if u.objectId == PFUser.currentUser()?.objectId {
                    IdidVote1 = true
                    break
                }
            }
        }else {
            return nil
        }
        if let vote2Arr = parseObject[PFKey.SPOTLIGHT.VOTE2] as? [PFUser] {
            countVote2 = vote2Arr.count
            for u in vote2Arr {
                if u.objectId == PFUser.currentUser()?.objectId {
                    IdidVote2 = true
                    break
                }
            }
        }else {
            return nil
        }
        
        if let b = parseObject[PFKey.SPOTLIGHT.BONUS] as? Int {
            bonus = b
        }else {
            return nil
        }
        
        if let p = parseObject[PFKey.SPOTLIGHT.POINTS] as? Int {
            points = p
        }else {
            return nil
        }
        scores = bonus + countLikes * ExSpConstants.LIKE_HIT + countVote0 * ExSpConstants.VOTE0_HIT + countVote1 * ExSpConstants.VOTE1_HIT + countVote2 * ExSpConstants.VOTE2_HIT
    }
}
