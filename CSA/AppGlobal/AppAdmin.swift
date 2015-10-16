//
//  AppAdmin.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/6/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
struct AppAdmin { //Do not use it!
    static func DangerousBuildSpotlightUserDangerous() {
        if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
            if !isAdmin {
                print("Not admin")
                return
            }
        }
        let query = PFUser.query()!
        query.limit = 300
        query.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
            if let re = result as? [PFUser] {
                for u in re {
                    //Spotlight User
                    let newSpUser = PFObject(className: PFKey.SPOTLIGHT.CLASSKEY)
                    newSpUser[PFKey.IS_VALID] = true
                    newSpUser[PFKey.SPOTLIGHT.USER] = u
                    newSpUser[PFKey.SPOTLIGHT.IS_ON] = true
                    newSpUser[PFKey.SPOTLIGHT.POINTS] = 30
                    newSpUser[PFKey.SPOTLIGHT.BONUS] = 0
                    newSpUser[PFKey.SPOTLIGHT.LIKES] = []
                    newSpUser[PFKey.SPOTLIGHT.VOTE0] = []
                    newSpUser[PFKey.SPOTLIGHT.VOTE1] = []
                    newSpUser[PFKey.SPOTLIGHT.VOTE2] = []
                    newSpUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if error != nil{
                            print(error)
                        }
                    })
                }
            }
        })
    }
    static func dangerousResetSpotlightUserHits() {
        if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
            if !isAdmin {
                print("Not admin")
                return
            }
        }
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.limit = 300
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if let re = result as? [PFObject] {
                for u in re {
                    u[PFKey.SPOTLIGHT.LIKES] = []
                    u[PFKey.SPOTLIGHT.VOTE0] = []
                    u[PFKey.SPOTLIGHT.VOTE1] = []
                    u[PFKey.SPOTLIGHT.VOTE2] = []
                    u.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if error != nil{
                            print(error)
                        }
                    })

                }
            }else {
                print(error)
            }
        }
    }
    static func dangerousAddSpotlightUserPoints() {
        if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
            if !isAdmin {
                print("Not admin")
                return
            }
        }
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.limit = 300
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if let re = result as? [PFObject] {
                for u in re {
                    u.incrementKey(PFKey.SPOTLIGHT.POINTS, byAmount: 30)
                    u.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if error != nil{
                            print(error)
                        }
                    })
                    
                }
            }else {
                print(error)
            }
        }
    }
    
    static func DangerousResetSpotlightUserPoints() {
        if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
            if !isAdmin {
                print("Not admin")
                return
            }
        }
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.limit = 300
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if let re = result as? [PFObject] {
                for u in re {
                    u[PFKey.SPOTLIGHT.POINTS] = 0
                    u.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if error != nil{
                            print(error)
                        }
                    })

                }
            }else {
                print(error)
            }
        }
    }
    static func dangerousCreateNotifForAllUsers() {
        if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
            if !isAdmin {
                print("Not admin\n", terminator: "")
                return
            }
        }
        let forType = AppNotif.NotifType.NEW_BULLETIN
        let withMessage = "New Event - Hotpot Night. Signup needed!"
        let query = PFUser.query()!
        query.limit = 300
        query.findObjectsInBackgroundWithBlock({ (result:[AnyObject]?, error:NSError?) -> Void in
            if let re = result as? [PFUser] {
                for u in re {
                    //Spotlight User
                    let newNotif = PFObject(className: PFKey.NOTIFICATION.CLASSKEY)
                    newNotif[PFKey.IS_VALID] = true
                    newNotif[PFKey.NOTIFICATION.USER] = u
                    newNotif[PFKey.NOTIFICATION.TYPE] = forType
                    newNotif[PFKey.NOTIFICATION.MESSAGE] = withMessage
                    newNotif.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if error != nil{
                            print("\(error)\n", terminator: "")
                        }
                    })
                }
            }
        })
    }
    static func dangerousPushNotifForInstall() {
        /*if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
            if !isAdmin {
                print("Not admin\n", terminator: "")
                return
            }
        }*/
        // Create our Installation query
        let pushQuery = PFInstallation.query()!
        pushQuery.whereKey(PFKey.OBJECT_ID, equalTo: "")
        // Send push notification to query
        let push = PFPush()
        let data = [
            "alert" : "你好，你的账号有些问题，请Log out再重新登陆，谢谢啦！",
            "badge" : "Increment",
            AppNotif.NotifType.KEY : "admin"
        ]
        push.setQuery(pushQuery) // Set our Installation query
        push.setData(data)
        push.sendPushInBackground()
    }
    
    static func dangerousPushNotifForUserID(withMessage:String){
        /*if let isAdmin = ((PFUser.currentUser()!)[PFKey.USER.IS_ADMIN]) as? Bool {
        if !isAdmin {
        print("Not admin\n", terminator: "")
        return
        }
        }*/
        // Create our Installation query
        let pushQuery = PFInstallation.query()!
        let uQuery = PFUser.query()
        let toUser = uQuery?.getObjectWithId("")
        pushQuery.whereKey(PFKey.INSTALL.BINDED_USER, equalTo: toUser!)
        // Send push notification to query
        let push = PFPush()
        let data = [
            "alert" : withMessage,
            "badge" : "Increment",
            "sound" : AppConstants.SoundFile.NOTIF_1,
            AppNotif.NotifType.KEY : AppNotif.NotifType.ADMIN_DIRECT
        ]
        push.setQuery(pushQuery) // Set our Installation query
        push.setData(data)
        push.sendPushInBackground()
        //add notification to database
        let newNotif = PFObject(className: PFKey.NOTIFICATION.CLASSKEY)
        newNotif[PFKey.IS_VALID] = true
        newNotif[PFKey.NOTIFICATION.USER] = toUser
        newNotif[PFKey.NOTIFICATION.TYPE] = AppNotif.NotifType.ADMIN_DIRECT
        newNotif[PFKey.NOTIFICATION.MESSAGE] = withMessage
        newNotif.saveInBackground()
    }
}