//
//  StoryboardID.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/11/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import Foundation
struct StoryboardID {
    struct EVENT{
        static let DETAIL = "eventDetailVC"
        static let SIGN_UP = "eventSignUpVC"
        static let DISCUSSION = "eventDiscussVC"
    }
    struct RENDEZVOUS{
        static let GOING = "rsGoingVC"
        static let LIKE = "rsLikeVC"
        static let COMMENT = "RendezvousCommentVC"
    }
    struct QA {
        static let MAIN = "QAVC"
        static let QUESTION = "QAQuestionVC"
        static let ANSWER = "QAAnswerVC"
        static let STAT = "StatViewVC"
    }
    static let LOGIN = "loginVC"
    static let USER_INFO = "userProfileVC"
    static let PROFILE_EDIT = "editProfileVC"
    static let ZOOM_IMAGE = "zoomImageVC"
}
