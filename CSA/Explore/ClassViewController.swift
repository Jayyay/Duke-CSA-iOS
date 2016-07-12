//
//  ClassViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/4/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class ClassViewController: UITableViewController, UISearchControllerDelegate {
    
    var delegate: LoadClassesResourceDelegate!
    var courses: [[Course]] = [] // 2D array with section
    var courseList: [Course] = [] // array of all courses
    var courseIndexList: [String] = [] // index list: [A, B, C...]
    var filteredCourses: [Course] = [] // used by search controller
    var selectedCourse: Course! // passed to ClassDetailController
    
    let ReuseID_CourseCell = "CourseCell"
    let ReuseID_LoadingCell = "LoadingCell"
    let ReuseID_CourseDetailSegue = "CourseDetailSegue"
    let ReuseID_NoResultCell = "NoResultCell"
    
    let Scope_All = "All"
    let Scope_Number = "Number"
    let Scope_Name = "Name"
    let Scope_Professor = "Professor"
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "CourseCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_CourseCell)
        nib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_LoadingCell)
        nib = UINib(nibName: "NoResultCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_NoResultCell)
        
        // search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.scopeButtonTitles = [Scope_All, Scope_Number, Scope_Name, Scope_Professor]
        searchController.searchBar.placeholder = "COMPSCI 330 / Algorithms / Ahar"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // prevent the index list from covering the searchbar
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        
        // load json data
        delegate = LoadClasses()
        delegate.loadCoursesWithBlock {
            self.courses = AppData.ClassData.courses
            self.courseIndexList = AppData.ClassData.courseIndexList
            self.courseList = AppData.ClassData.courseList
            self.navigationItem.title = String(self.courseList.count) + " Comments"
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
            if filteredCourses.count == 0 {
                return 1
            } else {
                return filteredCourses.count
            }
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
        // no course data yet
        if (courses.count == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_LoadingCell) as! LoadingCell
            return cell
        }
        // no search result
        if (searchController.active && searchController.searchBar.text != "" && filteredCourses.count == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_NoResultCell)!
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_CourseCell) as! CourseCell
        var course: Course!
        // search result
        if searchController.active && searchController.searchBar.text != "" {
            course = filteredCourses[indexPath.row]
        }
        else { // list courses
            course = courses[indexPath.section][indexPath.row]
        }
        cell.initWithCourse(course)
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (searchController.active && searchController.searchBar.text != "") {
            selectedCourse = filteredCourses[indexPath.row]
        }
        else {
            selectedCourse = courses[indexPath.section][indexPath.row]
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier(ReuseID_CourseDetailSegue, sender: self)
    }
    
    // MARK: - Search functions
    
    func filterCourseForSearchText(searchText: String, scope: String) {
        filteredCourses = courseList.filter { course in
            let lowerCase = searchText.lowercaseString
            let containsNumber = course.number.lowercaseString.containsString(lowerCase)
            let containsName = course.name.lowercaseString.containsString(lowerCase)
            let containsProfessor = course.professor.lowercaseString.containsString(lowerCase)
            switch (scope) {
            case Scope_All:
                return containsName || containsNumber || containsProfessor
            case Scope_Number:
                return containsNumber
            case Scope_Name:
                return containsName
            case Scope_Professor:
                return containsProfessor
            default:
                return false
            }
        }
        if scope == Scope_All {
            filteredCourses.sortInPlace({AppTools.compareCourseIsSearchedBefore($0, c2: $1)})
        }
        tableView.reloadData()
    }
    
    // MARK: - Segue to ClassDetailController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! ClassDetailController
        destination.selectedCourse = self.selectedCourse
        destination.navigationItem.title = self.selectedCourse.number
    }
}

extension ClassViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        AppData.ClassData.searchText = searchController.searchBar.text!
        filterCourseForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension ClassViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterCourseForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
