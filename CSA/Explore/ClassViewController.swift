//
//  ClassViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/4/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class ClassViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    var delegate: LoadClassesResourceDelegate!
    var courses: [[Course]] = []
    var courseList: [Course] = []
    var courseIndexList: [String] = []
    var filteredCourses: [Course] = []
    
    let ReuseID_CourseCell = "CourseCell"
    let ReuseID_LoadingCell = "LoadingCell"
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "CourseCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_CourseCell)
        nib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_LoadingCell)
        
        // search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // load json data
        delegate = LoadClasses()
        delegate.loadCoursesWithBlock {
            self.courses = AppData.ClassData.courses
            self.courseIndexList = AppData.ClassData.courseIndexList
            self.courseList = AppData.ClassData.courseList
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        return courses.count > 0 ? courses.count : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCourses.count
        }
        if (courses.count == 0) {
            return 1 // loading
        }
        return courses[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (courses.count == 0) {
            return nil
        }
        if (searchController.active && searchController.searchBar.text != "") {
            return nil
        }
        return courseIndexList[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if (searchController.active) {
            return nil
        }
        return courseIndexList
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (courses.count == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_LoadingCell) as! LoadingCell
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_CourseCell) as! CourseCell
        var course: Course!
        if searchController.active && searchController.searchBar.text != "" {
            course = filteredCourses[indexPath.row]
        }
        else {
            course = courses[indexPath.section][indexPath.row]
        }
        cell.initWithCourse(course)
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    // MARK: - Search functions
    
    func filterCourseForSearchText(searchText: String, scope: String = "All") {
        filteredCourses = courseList.filter { course in
            let lowerCase = searchText.lowercaseString
            let containsNumber = course.number.lowercaseString.containsString(lowerCase)
            let containsName = course.name.lowercaseString.containsString(lowerCase)
            return containsName || containsNumber
        }
        tableView.reloadData()
    }
}

extension ClassViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterCourseForSearchText(searchController.searchBar.text!)
    }
}
