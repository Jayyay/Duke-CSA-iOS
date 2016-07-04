//
//  LoadClasses.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/4/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation

protocol LoadClassesResourceDelegate: class {
    func loadCoursesWithBlock(completion: () -> ())
    func initCourses()
}

class LoadClasses: LoadClassesResourceDelegate {
    var json: [AnyObject]!
    var courses: [[Course]] = []
    var courseIndexList: [String] = []
    
    func loadCoursesWithBlock(completion: () -> ()) {
        let query = PFQuery(className: PFKey.Class.CLASSKEY)
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if let re = result {
                if let source = re[0][PFKey.Class.SOURCE] as? PFFile {
                    source.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                        if let data = data {
                            do {
                                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                                if let unwrappedJSON = jsonObject as? [AnyObject]{
                                    self.json = unwrappedJSON
                                    AppData.ClassData.json = self.json
                                    self.initCourses()
                                    completion()
                                }
                            } catch {
                                print(error)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func initCourses() {
        var currentPivot = " "
        var currentSection = -1
        for i in 0..<json.count {
            if let course = json[i] as? [String: AnyObject] {
                let number = course[PFKey.Class.Column.NUMBER] as? String
                let name = course[PFKey.Class.Column.NAME] as? String
                let professor = course[PFKey.Class.Column.PROFESSOR] as? String
                let semester = course[PFKey.Class.Column.SEMESTER] as? String
                let comments = course[PFKey.Class.Column.COMMENTS] as? String
                let major = course[PFKey.Class.Column.MAJOR] as? String
                let courseObject = Course(number: number, name: name, professor: professor, semester: semester, comments: comments, major: major)
                
                let pivot = courseObject.getPivot()
                if (pivot != currentPivot) {
                    currentSection += 1
                    courseIndexList.append(pivot)
                    courses.append([])
                    currentPivot = pivot
                }
                courses[currentSection].append(courseObject)
            }
        }
        AppData.ClassData.courses = courses
        AppData.ClassData.courseIndexList = courseIndexList
        print(courses.count)
    }
}
