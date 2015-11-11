//
//  AppNotification.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/3/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
class Notification:NSObject {
    var PFInstance:PFObject
    var user:PFUser!
    var type:String = ""
    var message:String = ""
    var createdAt:NSDate!
    init?(parseObject:PFObject) {
        PFInstance = parseObject
        super.init()
        if let u = parseObject[PFKey.NOTIFICATION.USER] as? PFUser {
            user = u
        }else {
            return nil
        }
        if let t = parseObject[PFKey.NOTIFICATION.TYPE] as? String {
            type = t
        }else {
            return nil
        }
        if let m = parseObject[PFKey.NOTIFICATION.MESSAGE] as? String {
            message = m
        }else {
            return nil
        }
        if let c = parseObject.createdAt {
            createdAt = c
        }else {
            return nil
        }
    }
}
struct AppNotif {
    static let KEY = "message"
     struct NotifType {
        static let KEY = "notifType"
        static let NEW_EVENT = "newEvent"
        static let NEW_BULLETIN = "newBulletin"
        static let NEW_RENDEZVOUS = "newRs"
        static let MUTUAL_CRUSH = "mutualCrush"
        static let NEW_RS_REPLY = "newRsReply"
        static let NEW_RS_REPLY_RE = "newRsReplyRe"
        static let NEW_RS_LIKE = "newRsLike"
        static let NEW_RS_GOING = "newRsGoing"
        static let NEW_EDIS_REPLY = "newEvDisRe"
        static let NEW_EDISRE_REPLY = "newEvReRe"
        static let ADMIN_DIRECT = "admin"
    }
    
    struct Channels {
        static let KEY = "channels"
        static let ALL = "all"
    }
    static func pushNotificationToAll(message message:String,withSoundName:String) {
        //let push = PFPush()
        // Be sure to use the plural 'setChannels'.
        /*
        push.setMessage("The Giants won against the Mets 2-3.")
        push.sendPushInBackground()*/
    }
    static func pushNotification(forType forType:String, withMessage:String, toUser:PFUser, withSoundName:String) {
        // Create our Installation query
        let pushQuery = PFInstallation.query()!
        pushQuery.whereKey(PFKey.INSTALL.BINDED_USER, equalTo: toUser)
        // Send push notification to query
        let push = PFPush()
        let data = [
            "alert" : withMessage,
            "badge" : "Increment",
            "sound" : withSoundName,
            KEY : withMessage,
            NotifType.KEY : forType
        ]
        push.setQuery(pushQuery) // Set our Installation query
        push.setData(data)
        push.sendPushInBackground()
        //add notification to database
        let newNotif = PFObject(className: PFKey.NOTIFICATION.CLASSKEY)
        newNotif[PFKey.IS_VALID] = true
        newNotif[PFKey.NOTIFICATION.USER] = toUser
        newNotif[PFKey.NOTIFICATION.TYPE] = forType
        newNotif[PFKey.NOTIFICATION.MESSAGE] = withMessage
        newNotif.saveInBackground()
    }
}
