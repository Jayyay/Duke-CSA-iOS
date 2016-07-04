//
//  Course.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/4/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation

class Course {
    var number: String!
    var name: String!
    var professor: String!
    var semester: String!
    var comments: String!
    var major: String!
    
    init (number: String?, name: String?, professor: String?, semester: String?, comments: String?, major: String?) {
        if let number = number {
            self.number = number
        }
        if let name = name {
            self.name = name
        }
        if let professor = professor {
            self.professor = professor
        }
        if let semester = semester {
            self.semester = semester
        }
        if let comments = comments {
            self.comments = comments
        }
        if let major = major {
            self.major = major
        }
    }
    
    func getPivot() -> String! {
        return number.substringToIndex(number.startIndex.successor())
    }
}
