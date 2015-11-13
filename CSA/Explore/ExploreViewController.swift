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
    let REUSEID_FIRST = "IDFirstCell"
    let REUSEID_SECOND = "IDSecondCell"
    
    
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
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(REUSEID_FIRST, forIndexPath: indexPath)
            AppFunc.setCellTransparent(cell)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(REUSEID_SECOND, forIndexPath: indexPath)
            AppFunc.setCellTransparent(cell)
            return cell
        }
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
