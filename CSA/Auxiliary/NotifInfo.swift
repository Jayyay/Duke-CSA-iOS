//
//  NotifInfo.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/12/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation

class NotifInfo: NSObject, NSCoding {
    
    struct propertyKey {
        static let eventsKey = "events"
        static let rendezvousKey = "rendezvous"
        static let questionsKey = "questions"
        static let answersKey = "answers"
    }
    
    // objects that will get rid of notif badge
    var events: [String] = []
    var rendezvous: [String] = []
    var questions: [String] = []
    var answers: [String] = []
    
    // file path
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("NotifInfo")
    
    init? (events: [String], rendezvous: [String], questions: [String], answers: [String]) {
        self.events = events
        self.questions = questions
        self.rendezvous = rendezvous
        self.answers = answers
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let events = aDecoder.decodeObjectForKey(propertyKey.eventsKey) as! [String]
        let rendezvous = aDecoder.decodeObjectForKey(propertyKey.rendezvousKey) as! [String]
        let questions = aDecoder.decodeObjectForKey(propertyKey.questionsKey) as! [String]
        let answers = aDecoder.decodeObjectForKey(propertyKey.answersKey) as! [String]
        self.init(events: events, rendezvous: rendezvous, questions: questions, answers: answers)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(events, forKey: propertyKey.eventsKey)
        aCoder.encodeObject(rendezvous, forKey: propertyKey.rendezvousKey)
        aCoder.encodeObject(questions, forKey: propertyKey.questionsKey)
        aCoder.encodeObject(answers, forKey: propertyKey.answersKey)
    }
    
    func save() -> Bool {
        return NSKeyedArchiver.archiveRootObject(self, toFile: NotifInfo.ArchiveURL!.path!)
    }
}
