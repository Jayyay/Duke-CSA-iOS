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
        query.findObjectsInBackgroundWithBlock({ (result:[PFObject]?, error:NSError?) -> Void in
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
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if let re = result {
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
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if let re = result {
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
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if let re = result {
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
}
