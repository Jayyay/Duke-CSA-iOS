//
//  AppData.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/15/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
struct AppData {
    /*
    struct GeneralData {
        static var mainTabBarVC:TabBarController!
    }
    */
    struct ImageData {
        static var userPropicMode = false
        static var selectedUser:PFUser!
        static var selectedImage:UIImage!
        static func wipeSelectedImageData() {
            userPropicMode = false
            selectedUser = nil
            selectedImage = nil
        }
    }
    struct EventData {
        static var selectedEvent:Event!
        static var signupVC:EventSignUpViewController!
        static var discussVC:EventDiscussViewController!
        static func wipeSelectedEventData() {
            selectedEvent = nil
            signupVC = nil
            discussVC = nil
        }
    }
    
    struct BulletinData {
        static var selectedBulletin:Bulletin!
        static func wipeSelectedBulletinData() {
            selectedBulletin = nil
        }
    }
    
    struct RendezvousData {
        static var selectedRendezvous:Rendezvous!
        static var postVC:RsPostViewController!
        static var goingVC:RsGoingTableViewController!
        static var likeVC:RsLikeTableViewController!
        static func wipeSelectedRsData() {
            selectedRendezvous = nil
            goingVC = nil
            likeVC = nil
        }
    }
    
    struct QAData {
        static var selectedQAQuestion:QAPost!
        static var selectedQAAnswer: QAPost!
        static var postVC:QAComposeQuestionController!
        static var myAnswer: QAPost?
        static var myQuestion: QAPost?
        static func wipeSelectedQAData() {
            selectedQAQuestion = nil
            selectedQAAnswer = nil
        }
    }
    
    struct ClassData {
        static var json: [AnyObject]? = nil
        static var courses: [[Course]] = []
        static var courseIndexList: [String] = []
        static var courseList: [Course] = []
        static var searchText = ""
    }
    
    struct CrushData {
        static var myCrusherArray:[ExCrush] = []
        static var myCrusherDict:[String:Bool] = [:]
        static func buildMyCrusherDict() {
            myCrusherDict.removeAll(keepCapacity: true)
            for c in myCrusherArray {
                myCrusherDict[c.crusher.objectId!] = true
            }
        }
        
        static var myCrusheeArray:[ExCrush] = []
        static var myCrusheeDict:[String:Bool] = [:]
        static func buildMyCrusheeDict() {
            myCrusheeDict.removeAll(keepCapacity: true)
            for c in myCrusheeArray {
                myCrusheeDict[c.crushee.objectId!] = true
            }
        }
        
        static var detailVC:ExCrushDetailViewController!
        static func wipeCrushee() {
            myCrusheeArray.removeAll(keepCapacity: false)
            myCrusherArray.removeAll(keepCapacity: false)
        }
        static func wipeCrushData() {
            myCrusheeArray.removeAll(keepCapacity: false)
            myCrusheeDict.removeAll(keepCapacity: false)
            myCrusherArray.removeAll(keepCapacity: false)
            myCrusherDict.removeAll(keepCapacity: false)
            detailVC = nil
        }
    }
    
    struct NotifData {
        static var notifInfo: NotifInfo?
        static var notification: [NSObject: AnyObject]?
    }
    
    struct SpotlightData {
        static var mySpotlightPFInstance:PFObject!
    }
    
}
