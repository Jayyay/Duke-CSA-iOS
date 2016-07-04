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
    var courses: [Course] = []
    
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
            if let courses = AppData.ClassData.courses {
                self.courses = courses
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courses.count > 0 ? courses.count : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (courses.count == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_LoadingCell) as! LoadingCell
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_CourseCell) as! CourseCell
        cell.initWithCourse(courses[indexPath.row])
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
