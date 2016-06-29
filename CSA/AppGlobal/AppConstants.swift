//
//  AppConstants.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/29/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
struct AppConstants {
    struct Color {
        static let usernameColor = UIColor(red: 51/255, green: 102/255, blue: 153/255, alpha: 1.0)
        static let DukeBlue = UIColor(red: 7/255, green: 54/255, blue: 164/255, alpha: 1.0)
        static let DukeBlueTranslucent = UIColor(red: 7/255, green: 54/255, blue: 164/255, alpha: 0.6)
        static let cuteRed = UIColor(red: 233/255.0, green: 54/255.0, blue: 61/255.0, alpha: 1.0)
        static let placeholder = UIColor(red: 187/255, green: 186/255, blue: 193/255, alpha: 1.0)
        static let tintDefault = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0)
        static let color0 = UIColor(red: 216, green: 0, blue: 0, alpha: 1.0)
    }
    struct ColorSet0 {
        static let c0 = UIColor(red: 248/255, green: 177/255, blue: 149/255, alpha: 1) //rgb(248, 177, 149)
        static let c1 = UIColor(red: 246/255, green: 114/255, blue: 128/255, alpha: 1) //rgb(246, 114, 128)
        static let c2 = UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 1) //rgb(192, 108, 132)
        static let c3 = UIColor(red: 108/255, green: 91/255, blue: 123/255, alpha: 1) //rgb(108, 91, 123)
        static let c4 = UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1) //rgb(53, 92, 125)
    }
    struct SoundFile {
        static let NOTIF_1 = "notif1.mp3"
    }
    struct Prompt {
        static let REFRESH_FAILED = "Refresh failed. Please check your internet connection."
        static let ERROR = "Error. Please check your internet connection."
    }
    struct Vote {
        static let DOWNVOTE_HIGHLIGHT = UIImage(named:"downvote-highlight.png")
        static let DOWNVOTE_PLAIN = UIImage(named:"downvote-plain.png")
        static let UPVOTE_HIGHLIGHT = UIImage(named:"upvote-highlight.png")
        static let UPVOTE_PLAIN = UIImage(named:"upvote-plain.png")
    }
}