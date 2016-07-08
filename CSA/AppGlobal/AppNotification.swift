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
    static let INSTANCE_ID = "PFInstanceID"
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
        static let NEW_QA_ANSWER = "newQAAnswer"
        static let NEW_QA_REPLY = "newQAReply"
        static let NEW_QA_REPLY_RE = "newQAReplyRe"
        static let NEW_QA_VOTE_QUESTION = "newQAVoteQuestion"
        static let NEW_QA_VOTE_ANSWER = "newQAVoteAnswer"
        static let ADMIN_DIRECT = "admin"
    }
    
    struct Channels {
        static let KEY = "channels"
        static let ALL = "all"
    }
    
    static func pushNotificationToAll(message message:String,withSoundName:String) {
        let data = [
            "badge": "Increment",
            "message": message,
            "sound": withSoundName
        ]
        PFCloud.callFunctionInBackground("push", withParameters: ["channels": ["all"], "data": data])
    }
    
    static func pushNotification(forType forType:String, withMessage:String, toUser:PFUser, withSoundName:String, PFInstanceID: String) {
        let data = [
            "alert" : withMessage,
            "badge" : "Increment",
            "sound" : withSoundName,
            KEY : withMessage,
            NotifType.KEY : forType,
            INSTANCE_ID: PFInstanceID
        ]
        PFCloud.callFunctionInBackground("push", withParameters: ["toUser": toUser.objectId!, "data": data])
        
        //add notification to database
        let newNotif = PFObject(className: PFKey.NOTIFICATION.CLASSKEY)
        newNotif[PFKey.IS_VALID] = true
        newNotif[PFKey.NOTIFICATION.USER] = toUser
        newNotif[PFKey.NOTIFICATION.TYPE] = forType
        newNotif[PFKey.NOTIFICATION.MESSAGE] = withMessage
        newNotif.saveInBackground()
    }
    
    static var rootVC: TabBarController!
    
    static func goToVCWithNotification(notification: [NSObject : AnyObject]) {
        rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController! as! TabBarController
        if let type = notification[NotifType.KEY] as? String {
            switch (type) {
            case NotifType.NEW_QA_ANSWER:
                presentQAQuestionWithNotification(notification)
                break
            case NotifType.NEW_QA_REPLY, NotifType.NEW_QA_REPLY_RE:
                presentQAAnswerWithNotification(notification)
                break
            case NotifType.NEW_RS_LIKE, NotifType.NEW_RS_GOING, NotifType.NEW_RS_REPLY, NotifType.NEW_RS_REPLY_RE:
                presentRsWithNotification(notification)
                break
            default:
                print("not implemented yet")
            }
        }
        else {
            print("no notification type found.")
        }
    }
    
    static func presentQAQuestionWithNotification(notification: [NSObject: AnyObject]) {
        rootVC.selectedIndex = 2
        let ExploreNavController = rootVC.selectedViewController! as! UINavigationController
        let QAVC = ExploreNavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.MAIN)
        ExploreNavController.pushViewController(QAVC, animated: false)
        let query = PFQuery(className: PFKey.QA.CLASSKEY)
        let pfid = notification[INSTANCE_ID] as! String
        query.whereKey(PFKey.OBJECT_ID, equalTo: pfid)
        query.includeKey(PFKey.QA.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) in
            if let re = result {
                let question = re[0]
                AppData.QAData.selectedQAQuestion = QAPost(parseObject: question)
                let questionVC = QAVC.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.QUESTION)
                QAVC.navigationController!.pushViewController(questionVC, animated: false)
            }
            if let error = error {
                print("Error getting to Question View: ", error)
            }
        }
    }
    
    static func presentQAAnswerWithNotification(notification: [NSObject: AnyObject]) {
        rootVC.selectedIndex = 2
        let ExploreNavController = rootVC.selectedViewController! as! UINavigationController
        let QAVC = ExploreNavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.MAIN)
        ExploreNavController.pushViewController(QAVC, animated: false)
        let query = PFQuery(className: PFKey.QA.CLASSKEY)
        
        // get question and answer id
        let pfid = notification[INSTANCE_ID] as! String
        let colonRange = pfid.rangeOfString(":")!
        let questionId = pfid.substringWithRange(pfid.startIndex..<colonRange.startIndex)
        let answerId = pfid.substringWithRange(colonRange.endIndex..<pfid.endIndex)
        
        query.whereKey(PFKey.OBJECT_ID, equalTo: questionId)
        query.includeKey(PFKey.QA.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) in
            if let re = result {
                let question = re[0]
                AppData.QAData.selectedQAQuestion = QAPost(parseObject: question)
                let questionVC = QAVC.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.QUESTION)
                QAVC.navigationController!.pushViewController(questionVC, animated: false)
                
                let queryAnswer = PFQuery(className: PFKey.QA.CLASSKEY)
                queryAnswer.whereKey(PFKey.OBJECT_ID, equalTo: answerId)
                queryAnswer.includeKey(PFKey.QA.AUTHOR)
                queryAnswer.cachePolicy = PFCachePolicy.NetworkOnly
                queryAnswer.findObjectsInBackgroundWithBlock({ (result: [PFObject]?, error: NSError?) in
                    if let re = result {
                        let answer = re[0]
                        AppData.QAData.selectedQAAnswer = QAPost(parseObject: answer)
                        let answerVC = questionVC.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.ANSWER)
                        questionVC.navigationController!.pushViewController(answerVC, animated: false)
                    }
                    if let error = error {
                        print("Error getting to Answer View: ", error)
                    }
                })
            }
            if let error = error {
                print("Error getting to Question View: ", error)
            }
        }
    }
    
    static func presentRsWithNotification(notification: [NSObject: AnyObject]) {
        rootVC.selectedIndex = 1
        let RsNavController = rootVC.selectedViewController! as! UINavigationController
        
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        let pfid = notification[INSTANCE_ID] as! String
        query.whereKey(PFKey.OBJECT_ID, equalTo: pfid)
        query.includeKey(PFKey.RENDEZVOUS.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) in
            if let re = result {
                let rs = re[0]
                AppData.RendezvousData.selectedRendezvous = Rendezvous(parseObject: rs)
                let RsCommentVC = RsNavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.RENDEZVOUS.COMMENT)
                RsNavController.pushViewController(RsCommentVC, animated: false)
            }
            if let error = error {
                print("Error getting to Rendezvous Comment View: ", error)
            }
        }
    }
}
