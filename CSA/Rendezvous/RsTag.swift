//
//  RsTag.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/24/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
struct RsTag {
    static let all = "all"
    static let sport = "sport"
    static let dine = "dine"
    static let event = "event"
    static let play = "play"
    static let other = "other"
    
    //remember to change the order when you make changes in IB
    static let tagIndexToName = [sport, dine, event, play, other]
    
    //change this according to storyboard setting
    static let colorDict:[String:(r:CGFloat, g:CGFloat, b:CGFloat)] = [
        all : (0, 0, 0),
        sport : (34, 197, 251),
        dine : (242, 207, 52),
        event : (175, 235, 169),
        play : (225, 181, 236),
        other : (211, 244, 239)
    ]
}