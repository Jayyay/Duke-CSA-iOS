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
    
    struct RendezvousStatus {
        static var lastRefreshTime:NSDate?
        static var tableShouldRefresh = true
        static var currentlyDisplayedView: ViewName = ViewName.Reply
        enum ViewName:Int{
            case Reply = 0, Going = 1, Like = 2
        }
    }
    
    struct QAStatus {
        static var lastRefreshTime:NSDate?
        static var QAShouldRefresh = true
        static var questionShouldRefresh = true
        static var currentlyDisplayedView: ViewName = ViewName.Reply
        static var order: QAPostOrder = .Vote
        enum ViewName:Int{
            case Reply = 0, Going = 1, Like = 2
        }
        enum QAPostOrder {
            case Vote
            case New
        }
    }
    
    struct MeTableStatus {
        static var tableShouldRefreshLocally = false
    }
}
