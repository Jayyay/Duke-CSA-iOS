//
//  Bulletin.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/13/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class Bulletin: NSObject {
    //required
    let PFInstance:PFObject
    var title:String!
    var detail:String!
    var createdAt:NSDate!
    
    //optional
    var subtitle:String?
    var date:NSDate?
    var location:String?
    
    init?(parseObject:PFObject){
        PFInstance = parseObject
        super.init()
        
        //required. If not valid, a failure will be triggered and nil returned.
        if let t = parseObject[PFKey.BULLETIN.TITLE] as? String {
            title = t
        }else{
            return nil
        }
        if let d = parseObject[PFKey.BULLETIN.DETAIL] as? String {
            detail = d
        }else{
            return nil
        }
        if let c = parseObject.createdAt {
            createdAt = c
        }else{
            return nil
        }
        
        //optional
        subtitle = parseObject[PFKey.BULLETIN.SUBTITLE] as? String
        date = parseObject[PFKey.BULLETIN.WHEN] as? NSDate
        location = parseObject[PFKey.BULLETIN.WHERE] as? String
    }
}
