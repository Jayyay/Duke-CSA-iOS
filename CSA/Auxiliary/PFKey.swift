//
//  PFKey.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/8/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

struct PFKey {
    static let CREATED_AT = "createdAt"
    static let UPDATED_AT = "updatedAt"
    static let IS_VALID = "isValid"
    static let OBJECT_ID = "objectId"
    struct USER {
        static let CLASSKEY = "User"
        static let IS_ADMIN = "isAdmin"
        static let GENDER = "gender"
        static let REAL_NAME = "realName"
        static let BIRTHDAY = "birthday"
        static let NET_ID = "netID"
        static let DISPLAY_NAME = "displayName"
        static let EMAIL = "email"
        static let ABOUT_ME = "aboutMe"
        static let WHICH_YEAR = "whichYear"
        static let MAJOR = "major"
        static let MINOR = "minor"
        static let PROPIC_ORIGINAL = "profilePictureFile"
        static let PROPIC_COMPRESSED = "compressedPropicFile"
        static let CELL_PHONE = "cellPhone"
        static let RELATIONSHIP = "relationship"
        static let MYEVENTS_ARR = "myEvents"
    }
    struct INSTALL {
        static let BINDED_USER = "user"
        struct CHANNEL {
            static let EVENTS = "event"
            static let BULLETIN = "bulletin"
            static let RS = "rendezvous"
        }
    }
    struct EVENT {
        static let CLASSKEY = "Event"
        static let TITLE = "title"
        static let WHEN = "when"
        static let WHERE = "where"
        static let PICTURE = "eventPictureFile"
        static let DETAIL = "detail"
        static let NEED_SIGN_UP = "needToSignUp"
        static let OPEN_FOR_SIGN_UP = "openForSignUp"
        static let URL_FOR_SIGN_UP = "signUpUrl"
        
        struct DIS {
            static let CLASSKEY = "EventDis"
            static let PARENT = "event"
            static let AUTHOR = "author"
            static let MAIN_POST = "mainPost"
            static let LIKES = "likes"
            static let REPLIES = "replies"
            
            struct RE {
                static let CLASSKEY = "EventDisRe"
                static let PARENT = "eventDis"
                static let MAIN_POST = "mainPost"
                static let AUTHOR = "author"
                static let REPLY_TO = "replyTo"
            }
        }
    }
    struct BULLETIN {
        static let CLASSKEY = "Bulletin"
        static let TITLE = "title"
        static let SUBTITLE = "subtitle"
        static let WHEN = "when"
        static let WHERE = "where"
        static let TITPIC_DATA = "titlePicture"
        static let DETAIL = "detail"
        static let NEED_SIGN_UP = "needToSignUp"
    }
    struct RENDEZVOUS {
        static let CLASSKEY = "Rendezvous"
        static let AUTHOR = "author"
        static let TITLE = "title"
        static let WHEN_WHERE = "whenWhere"
        static let MAIN_POST = "mainPost"
        static let TAGS = "tags"
        
        static let GOINGS = "goings"
        static let LIKES = "likes"
        static let REPLIES = "replies"
        
        struct RE {
            static let CLASSKEY = "RsReply"
            static let PARENT = "rendezvous"
            static let MAIN_POST = "mainPost"
            static let AUTHOR = "author"
            static let IS_SUB = "isSubReply"
            static let REPLY_TO = "replyTo"
        }
    }
    struct SPOTLIGHT {
        static let CLASSKEY = "ExpSpotlight"
        static let IS_ON = "isOn"
        static let USER = "user"
        static let LIKES = "likes"
        static let VOTE0 = "vote0"
        static let VOTE1 = "vote1"
        static let VOTE2 = "vote2"
        static let BONUS = "bonus"
        static let POINTS = "points"
        
    }
    struct CRUSH {
        static let CLASSKEY = "ExpCrush"
        static let CRUSHER = "crusher"
        static let CRUSHEE = "crushee"
    }
    struct ABOUT_DUKE_CSA {
        static let CLASSKEY = "AboutDukeCSA"
        static let MAIN_POST = "mainPost"
    }
    
    struct ME {
        struct BUG_REPORT {
            static let CLASSKEY = "MeBugReport"
            static let AUTHOR = "author"
            static let MAIN_POST = "mainPost"
        }
        struct LEAVE_COMMENT {
            static let CLASSKEY = "MeComment"
            static let AUTHOR = "author"
            static let MAIN_POST = "mainPost"
        }
    }
    
    struct NOTIFICATION {
        static let CLASSKEY = "AppNotif"
        static let USER = "user"
        static let MESSAGE = "message"
        static let TYPE = "type"
    }
    
}