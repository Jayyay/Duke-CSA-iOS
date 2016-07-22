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
    var type: String = ""
    var message: String = ""
    var createdAt: NSDate!
    var instanceID: String = ""
    
    init?(parseObject:PFObject) {
        PFInstance = parseObject
        super.init()
        if let u = parseObject[PFKey.NOTIFICATION.USER] as? PFUser {
            user = u
        } else {
            return nil
        }
        if let t = parseObject[PFKey.NOTIFICATION.TYPE] as? String {
            type = t
        } else {
            return nil
        }
        if let m = parseObject[PFKey.NOTIFICATION.MESSAGE] as? String {
            message = m
        } else {
            return nil
        }
        if let c = parseObject.createdAt {
            createdAt = c
        } else {
            return nil
        }
        if let s = parseObject[AppNotif.INSTANCE_ID] as? String {
            instanceID = s
        } else {
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
        static let NEW_EVENT_REPLY = "newEvDisRe"
        static let NEW_EVENT_LIKE = "newEvLike"
        static let NEW_BULLETIN = "newBulletin"
        static let NEW_RENDEZVOUS = "newRs"
        static let MUTUAL_CRUSH = "mutualCrush"
        static let NEW_RS_REPLY = "newRsReply"
        static let NEW_RS_REPLY_RE = "newRsReplyRe"
        static let NEW_RS_LIKE = "newRsLike"
        static let NEW_RS_GOING = "newRsGoing"
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
            "content-available" : 1,
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
        newNotif[INSTANCE_ID] = PFInstanceID
        newNotif.saveInBackground()
    }
    
    static func retrieveNotifications() {
        if let user = PFUser.currentUser() {
            PFCloud.callFunctionInBackground("getNotifData", withParameters: ["userID": user.objectId!], block: { (result, error) in
                if let re = result as? [[NSObject:AnyObject]] {
                    for notification in re {
                        handleBadgeNotif(notification)
                    }
                    showBadgeOnTabbar()
                    print("after calling show badge");
                    PFCloud.callFunctionInBackground("wipeNotifData", withParameters: ["userID": user.objectId!])
                }
            })
        }
    }
    
    static var rootVC: TabBarController!
    
    static func goToVCWithNotification(notification: [NSObject : AnyObject]) {
        AppData.NotifData.notification = nil // prevent going through launching with notification again
        rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController! as! TabBarController
        if let type = notification[NotifType.KEY] as? String {
            switch (type) {
            case NotifType.NEW_QA_ANSWER, NotifType.NEW_QA_VOTE_QUESTION:
                presentQAQuestionWithNotification(notification)
                break
            case NotifType.NEW_QA_REPLY, NotifType.NEW_QA_REPLY_RE, NotifType.NEW_QA_VOTE_ANSWER:
                presentQAAnswerWithNotification(notification)
                break
            case NotifType.NEW_RS_LIKE, NotifType.NEW_RS_GOING, NotifType.NEW_RS_REPLY, NotifType.NEW_RS_REPLY_RE:
                presentRsWithNotification(notification)
                break
            case NotifType.NEW_EVENT_LIKE, NotifType.NEW_EVENT_REPLY:
                presentEventDisWithNotification(notification)
                break
            case NotifType.NEW_EVENT:
                presentEventWithNotification(notification)
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
        rootVC.selectedIndex = 3
        let QANavController = rootVC.selectedViewController! as! UINavigationController
        let query = PFQuery(className: PFKey.QA.CLASSKEY)
        let pfid = notification[INSTANCE_ID] as! String
        query.whereKey(PFKey.OBJECT_ID, equalTo: pfid)
        query.includeKey(PFKey.QA.AUTHOR)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) in
            if let re = result {
                let question = re[0]
                AppData.QAData.selectedQAQuestion = QAPost(parseObject: question)
                let questionVC = QANavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.QUESTION)
                QANavController.pushViewController(questionVC, animated: false)
            }
            if let error = error {
                print("Error getting to Question View: ", error)
            }
        }
    }
    
    static func presentQAAnswerWithNotification(notification: [NSObject: AnyObject]) {
        rootVC.selectedIndex = 3
        let QANavController = rootVC.selectedViewController! as! UINavigationController
        
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
                let questionVC = QANavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.QA.QUESTION)
                QANavController.pushViewController(questionVC, animated: false)
                
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
    
    static func presentEventWithNotification(notification: [NSObject: AnyObject]) {
        rootVC.selectedIndex = 0
        let EventNavController = rootVC.selectedViewController! as! UINavigationController
        
        let query = PFQuery(className: PFKey.EVENT.CLASSKEY)
        let pfid = notification[INSTANCE_ID] as! String
        query.whereKey(PFKey.OBJECT_ID, equalTo: pfid)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) in
            if let re = result {
                let ev = re[0]
                AppData.EventData.selectedEvent = Event(parseObject: ev)
                let EventVC = EventNavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.EVENT.DETAIL)
                EventNavController.pushViewController(EventVC, animated: false)
                print("present detail")
            }
            if let error = error {
                print("Error getting to Event View: ", error)
            }
        }
    }
    
    static func presentEventDisWithNotification(notification: [NSObject: AnyObject]) {
        rootVC.selectedIndex = 0
        let EventNavController = rootVC.selectedViewController! as! UINavigationController
        
        let query = PFQuery(className: PFKey.EVENT.CLASSKEY)
        let pfid = notification[INSTANCE_ID] as! String
        query.whereKey(PFKey.OBJECT_ID, equalTo: pfid)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) in
            if let re = result {
                let ev = re[0]
                AppData.EventData.selectedEvent = Event(parseObject: ev)
                let EventVC = EventNavController.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.EVENT.DETAIL)
                EventNavController.pushViewController(EventVC, animated: false)
                let commentVC = EventVC.navigationController!.storyboard!.instantiateViewControllerWithIdentifier(StoryboardID.EVENT.DISCUSSION)
                EventVC.navigationController?.pushViewController(commentVC, animated: false)
            }
            if let error = error {
                print("Error getting to Event Comment View: ", error)
            }
        }
    }
    
    static func handleBadgeNotif(notification: [NSObject: AnyObject]) {
        let notifInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(NotifInfo.ArchiveURL!.path!) as? NotifInfo
        if let info = notifInfo {
            AppData.NotifData.notifInfo = info
            if let type = notification[NotifType.KEY] as? String {
                switch (type) {
                case NotifType.NEW_QA_ANSWER, NotifType.NEW_QA_VOTE_QUESTION:
                    let questionID = notification[INSTANCE_ID] as! String
                    let questions = AppData.NotifData.notifInfo!.questions
                    if (!questions.contains(questionID)) {
                        AppData.NotifData.notifInfo!.questions.append(questionID)
                        AppData.NotifData.notifInfo!.save()
                    }
                    break
                case NotifType.NEW_QA_REPLY, NotifType.NEW_QA_REPLY_RE, NotifType.NEW_QA_VOTE_ANSWER:
                    let pfid = notification[INSTANCE_ID] as! String
                    let colonRange = pfid.rangeOfString(":")!
                    let questionID = pfid.substringWithRange(pfid.startIndex..<colonRange.startIndex)
                    let answerID = pfid.substringWithRange(colonRange.endIndex..<pfid.endIndex)
                    let answers = AppData.NotifData.notifInfo!.answers
                    if (!answers.contains(answerID)) {
                        AppData.NotifData.notifInfo!.answers.append(answerID)
                        AppData.NotifData.notifInfo!.ansQuestions.append(questionID)
                        AppData.NotifData.notifInfo!.save()
                    }
                    break
                case NotifType.NEW_RS_LIKE, NotifType.NEW_RS_GOING, NotifType.NEW_RS_REPLY, NotifType.NEW_RS_REPLY_RE:
                    let rsid = notification[INSTANCE_ID] as! String
                    let rendezvous = AppData.NotifData.notifInfo!.rendezvous
                    if (!rendezvous.contains((rsid))) {
                        AppData.NotifData.notifInfo!.rendezvous.append(rsid)
                        AppData.NotifData.notifInfo!.save()
                    }
                    break
                case NotifType.NEW_EVENT_REPLY, NotifType.NEW_EVENT_LIKE:
                    let eventID = notification[INSTANCE_ID] as! String
                    let events = AppData.NotifData.notifInfo!.events
                    if (!events.contains(eventID)) {
                        AppData.NotifData.notifInfo!.events.append(eventID)
                        AppData.NotifData.notifInfo!.save()
                    }
                    break
                case NotifType.NEW_EVENT:
                    let eventID = notification[INSTANCE_ID] as! String
                    let newEvents = AppData.NotifData.notifInfo!.newEvents
                    if (!newEvents.contains(eventID)) {
                        AppData.NotifData.notifInfo!.newEvents.append(eventID)
                        AppData.NotifData.notifInfo!.save()
                    }
                    break
                default:
                    print("not implemented yet")
                }
            }
        }
    }
    
    static func showBadgeOnTabbar() {
        if let notif = AppData.NotifData.notifInfo {
            rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController! as! TabBarController
            
            let eventVC = rootVC.viewControllers![0] as! EventNavigationController
            let eventCount = notif.events.count + notif.newEvents.count
            if (notif.newEvents.count != 0) {
                AppStatus.EventStatus.tableShouldRefresh = true
            }
            eventVC.tabBarItem.badgeValue = eventCount == 0 ? nil : String(eventCount)
            
            let rsVC = rootVC.viewControllers![1] as! RsNavigationController
            let rsCount = notif.rendezvous.count
            rsVC.tabBarItem.badgeValue = rsCount == 0 ? nil : String(rsCount)
            
            let QAVC = rootVC.viewControllers![3]
            let qanda = notif.questions.count + notif.answers.count
            QAVC.tabBarItem.badgeValue = qanda == 0 ? nil : String(qanda)
            
            let installation = PFInstallation.currentInstallation()
            installation.badge = eventCount + rsCount + qanda
            installation.saveEventually()
        }
    }
}
