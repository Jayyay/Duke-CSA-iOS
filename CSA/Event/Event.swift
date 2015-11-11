//
//  Event.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/9/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class Event: NSObject {
    //required
    let PFInstance:PFObject
    var title:String!
    var date:NSDate!
    var location:String!
    var detail:String!
    var needToSignUp:Bool = false
    var openForSignUp:Bool = false
    var urlForSignUp:String!
    var createdAt:NSDate!
    
    //optional
    var shortTitle:String?
    
    
    //optional
    var pictureFile:[PFFile] = []
    
    init?(parseObject:PFObject){
        PFInstance = parseObject
        super.init()
        
        //required. If not valid, a failure will be triggered and nil returned.
        if let t = parseObject[PFKey.EVENT.TITLE] as? String{
            title = t
        }else{
            return nil
        }
        if let d = parseObject[PFKey.EVENT.WHEN] as? NSDate{
            date = d
        }else{
            return nil
        }
        if let l = parseObject[PFKey.EVENT.WHERE] as? String{
            location = l
        }else{
            return nil
        }
        if let d = parseObject[PFKey.EVENT.DETAIL] as? String{
            detail = d
        }else{
            return nil
        }
        if let n = parseObject[PFKey.EVENT.NEED_SIGN_UP] as? Bool{
            needToSignUp = n
        }else{
            return nil
        }
        if let o = parseObject[PFKey.EVENT.OPEN_FOR_SIGN_UP] as? Bool{
            openForSignUp = o
        }else{
            return nil
        }
        if needToSignUp && openForSignUp { //init url
            if let u = parseObject[PFKey.EVENT.URL_FOR_SIGN_UP] as? String{
                urlForSignUp = u
            }else {
                return nil
            }
        }
        if let c = parseObject.createdAt {
            createdAt = c
        }else{
            return nil
        }
        
        //optional
        //pictureFile = parseObject[PFKey.EVENT.PICTURE] as? PFFile
    }
}
