//
//  ExCrush.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/26/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class ExCrush: NSObject {
    let PFInstance:PFObject
    var crusher:PFUser!
    var crushee:PFUser!
    
    init?(parseObject:PFObject) {
        PFInstance = parseObject
        if let u = parseObject[PFKey.CRUSH.CRUSHER] as? PFUser {
            crusher = u
        }else{
            return
        }
        if let u = parseObject[PFKey.CRUSH.CRUSHEE] as? PFUser {
            crushee = u
        }else{
            return
        }
    }
    
}
