//
//  ClassViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/4/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class ClassViewController: UITableViewController {
    
    var delegate: LoadClassesResourceDelegate!
    var courses: [[Course]] = []
    var courseIndexList: [String] = []
    
    let ReuseID_CourseCell = "CourseCell"
    let ReuseID_LoadingCell = "LoadingCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "CourseCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_CourseCell)
        nib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_LoadingCell)
        
        // load json data
        delegate = LoadClasses()
        delegate.loadCoursesWithBlock {
            self.courses = AppData.ClassData.courses
            self.courseIndexList = AppData.ClassData.courseIndexList
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return courses.count > 0 ? courses.count : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (courses.count == 0) {
            return 1
        }
        return courses[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (courses.count == 0) {
            return nil
        }
        return courseIndexList[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return courseIndexList
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (courses.count == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_LoadingCell) as! LoadingCell
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_CourseCell) as! CourseCell
        cell.initWithCourse(courses[indexPath.section][indexPath.row])
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
}
