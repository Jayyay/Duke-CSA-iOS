//
//  AppStatus.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/10/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
struct AppStatus {
    
    struct EventStatus{
        static var lastRefreshTime:NSDate?
        static var tableShouldRefresh = true
        static var currentlyDisplayedView: ViewName = ViewName.Detail
        enum ViewName:Int{
            case Detail = 0, SignUp = 1, Discuss = 2
        }
    }
    
    struct BulletinStatus{
        static var lastRefreshTime:NSDate?
        static var tableShouldRefresh = true
        /*
        static var tableShouldQueryFromCache = true
        static var currentlyDisplayedView: ViewName = ViewName.Detail
        enum ViewName:Int{
            case Detail = 0, SignUp = 1, Discuss = 2
        }*/
    }
    
    struct RendezvousStatus {
        static var lastRefreshTime:NSDate?
        static var tableShouldRefresh = true
        static var currentlyDisplayedView: ViewName = ViewName.Reply
        enum ViewName:Int{
            case Reply = 0, Going = 1, Like = 2
        }
    }
    
    struct MeTableStatus {
        static var tableShouldRefreshLocally = false
    }
}