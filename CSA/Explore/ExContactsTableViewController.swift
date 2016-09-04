//
//  ExContactsTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 5/13/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExContactsTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var queryCompletionCounter = 0
    var contacts:[[ExContact]] = []
    var allCt:[ExContact] = []
    var filteredCt:[ExContact] = []
    var indexList:[String] = []
    let ReuseID_UserCell = "IDUserCell"
    var searchController:UISearchController!
    var filterMode = false
    var cancelFilter = false
    
    
    // MARK: - Data Query
    
    func refreshSelector() {
        print("Contacts Begin Refreshing")
        let query = PFUser.query()!
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.limit = 1000
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter += 1
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        }
    }

    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {return}
        if self.queryCompletionCounter >= 2 {
            refreshControl!.endRefreshing()
        }
    }
    
    func changeTitle() {
        let contactCount = allCt.count
        let contactStr = allCt.count <= 1 ? "Contact" : "Contacts"
        self.navigationItem.title = "\(contactCount) \(contactStr)"
    }
    
    func queryCompletionDataHandler(result result:[PFObject]!, error:NSError!) {
        print("Contacts query completed for the \(self.queryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) contacts")
            allCt.removeAll(keepCapacity: true)
            for re in result as! [PFUser]{
                if let u = ExContact(user: re) {
                    allCt.append(u)
                }
            }
            //This code is a hack. If change title immediately there would a quick inconsistency in title which looks ugly. So delay the change in 0.1s
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ExContactsTableViewController.changeTitle), userInfo: nil, repeats: false)
            allCt.sortInPlace({AppTools.compareUserIsOrderedBefore(u1: $0, u2: $1)})
            
            //configure contacts by seperating user by netID_pivot (last name)
            contacts.removeAll(keepCapacity: true)
            indexList.removeAll(keepCapacity: true)
            var curIndexPivot: String = " ", curSection = -1
            for ct in allCt {
                if AppTools.getNamePivot(ct.displayName) != curIndexPivot { //new index
                    //append new index
                    curIndexPivot = AppTools.getNamePivot(ct.displayName)
                    indexList.append(curIndexPivot)
                    //create new section for contacts
                    contacts.append([])
                    curSection += 1
                }
                contacts[curSection].append(ct)
            }
            tableView.reloadData()
        }else{
            print("query error: ", terminator: "")
            print(error)
        }
    }
    
    // MARK: - Search Bar
    func beginFilter(text text: String?, scope: String){
        if let searchText = text?.lowercaseString{
            filteredCt = allCt.filter({ (ct:ExContact) -> Bool in
                if !(scope == "All" || ct.year.lowercaseString == scope.lowercaseString){return false}
                if ct.realName.lowercaseString.rangeOfString(searchText) != nil{return true}
                if ct.displayName.lowercaseString.rangeOfString(searchText) != nil{return true}
                if ct.major.lowercaseString.rangeOfString(searchText) != nil{return true}
                if ct.minor.lowercaseString.rangeOfString(searchText) != nil{return true}
                if ct.netID.lowercaseString.rangeOfString(searchText) != nil{return true}
                return false
            })
        }else{
            filteredCt = allCt.filter({ (ct:ExContact) -> Bool in
                return (scope == "All" || ct.year.lowercaseString == scope.lowercaseString)
            })
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if cancelFilter {
            filterMode = false
            cancelFilter = false
        }else{
            filterMode = true
            let str = searchController.searchBar.text
            let scopes = searchController.searchBar.scopeButtonTitles!
            let index = searchController.searchBar.selectedScopeButtonIndex
            if AppTools.stringIsValid(str){
                beginFilter(text: str, scope:scopes[index])
            }else{
                beginFilter(text: nil, scope: scopes[index])
            }
        }
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(self.searchController)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancelFilter = true
    }
    
    // MARK: - Life Cycle
    func initUI() {
        
        self.navigationItem.title = "Contacts"
        
        refreshControl = UIRefreshControl()
        //refreshControl!.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl!.addTarget(self, action: #selector(ExContactsTableViewController.refreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        searchController = UISearchController(searchResultsController:nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Freshman", "Sophomore", "Junior", "Senior"]
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
        let nib = UINib(nibName: "TextUserCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_UserCell)
        
        // prevent the index list from covering the searchbar
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        refreshSelector()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.hidden = false
        navigationController?.navigationBarHidden = false
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if filterMode{
            return 1
        }
        else {
            return contacts.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterMode{
            return filteredCt.count
        }else{
            return contacts[section].count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_UserCell, forIndexPath: indexPath) as! TextUserCell
        if filterMode{
            cell.initWithUser(filteredCt[indexPath.row].PFInstance)
        }else{
            cell.initWithUser(contacts[indexPath.section][indexPath.row].PFInstance)
        }
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterMode{
            return nil
        }else{
            return indexList[section]
        }
    }
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if filterMode{
            return nil
        }else{
            return indexList
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextUserCell
        searchController.searchBar.hidden = true
        searchController.searchBar.resignFirstResponder()
        self.navigationController?.navigationBarHidden = false
        AppFunc.displayUserInfo(cell.childUser, fromVC: self)
    }

}
