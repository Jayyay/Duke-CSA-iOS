//
//  ExploreViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 11/10/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let REUSEID_FIRST = "IDCell0"
    let REUSEID_SECOND = "IDCell1"
    let REUSEID_THIRD = "IDCell2"
    let REUSEID_FOURTH = "IDCell3"
    let REUSEID_FIFTH = "IDCell4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var id:String
        switch indexPath.row {
        case 0:
            id = REUSEID_FIRST
        case 1:
            id = REUSEID_SECOND
        case 2:
            id = REUSEID_THIRD
        case 3:
            id = REUSEID_FOURTH
        default:
            id = REUSEID_FIFTH
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath)
        return cell

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
