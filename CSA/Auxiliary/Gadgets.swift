//
//  Gadgets.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/8/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit


class Gadgets: NSObject {
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }

}

class EventSingleton: NSObject {
    
    var displayName:String?
    var gender:String?
    var aboutMe:String?
    var proPic:UIImage?
    
    
    class var sharedInstance: EventSingleton{
        struct Static{
            static var onceToken:dispatch_once_t = 0
            static var instance:EventSingleton? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = EventSingleton()
        }
        return Static.instance!
    }
}

