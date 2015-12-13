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
    struct SoundFile {
        static let NOTIF_1 = "notif1.mp3"
    }
    struct Prompt {
        static let REFRESH_FAILED = "Refresh failed. Please check your internet connection."
        static let ERROR = "Error. Please check your internet connection."
    }
}