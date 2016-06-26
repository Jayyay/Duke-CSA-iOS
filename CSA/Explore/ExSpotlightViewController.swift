//
//  ExSpotlightViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 8/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExSpotlightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var viewRanking: UIView!
    @IBOutlet weak var viewPaperScroll: UIView!
    @IBOutlet weak var rankingTableView: UITableView!
    @IBOutlet weak var userTableView: UITableView!
    
    @IBOutlet weak var lblPrompt: UILabel!
    
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnGirls: UIButton!
    @IBOutlet weak var btnBoys: UIButton!
    
    @IBOutlet weak var btnRankBoys: UIButton!
    @IBOutlet weak var btnRankGirls: UIButton!
    
    let ReuseID_userCell = "IDSpotlightUserCell"
    let ReuseID_rankingCell = "IDSpotlightRankingCell"
    let ReuseID_rankingPlaceholderCell = "IDSpotlightRankingPlaceholderCell"
    
    //user table
    let filterNormalBGColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
    let filterChosenBGColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    let filterRankNormalBGColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    let filterRankChosenBGColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    var currentFilterGender:String = "all" {
        willSet{
            switch newValue {
            case "male":
                btnAll.backgroundColor = filterNormalBGColor
                btnGirls.backgroundColor = filterNormalBGColor
                btnBoys.backgroundColor = filterChosenBGColor
            case "female":
                btnAll.backgroundColor = filterNormalBGColor
                btnGirls.backgroundColor = filterChosenBGColor
                btnBoys.backgroundColor = filterNormalBGColor
            default:
                btnAll.backgroundColor = filterChosenBGColor
                btnGirls.backgroundColor = filterNormalBGColor
                btnBoys.backgroundColor = filterNormalBGColor
            }
        }
    }
    var spUsers:[[ExSpotlightUser]] = []
    var allSpUser:[ExSpotlightUser] = []
    var filteredSpUser:[ExSpotlightUser] = []
    var indexList:[String] = []
    var userTableRefresher:UIRefreshControl!
    
    //ranking table
    var rankContactsQueryCompletionCounter = 0
    var allRankSpUser:[ExSpotlightUser] = []
    var filteredRankSpUser:[ExSpotlightUser] = []
    var currentRankFilterGender:String = "male" {
        willSet{
            switch newValue {
            case "male":
                btnRankGirls.backgroundColor = filterRankNormalBGColor
                btnRankBoys.backgroundColor = filterRankChosenBGColor
            case "female":
                btnRankGirls.backgroundColor = filterRankChosenBGColor
                btnRankBoys.backgroundColor = filterRankNormalBGColor
            default:
                break
            }
        }
    }
    var rankingTableRefresher:UIRefreshControl!
    
    
    @IBOutlet weak var viewRankButton: UIView!
    
    
    
    @IBAction func onDisplayRanking(sender: AnyObject) {
        if (viewRanking.hidden) {
            displayRankingView()
        }else {
            hideRankingView()
        }
    }
    
    @IBAction func onClickAll(sender: AnyObject) {
        if currentFilterGender == "all" {
            return
        }
        currentFilterGender = "all"
        beginFilter()
        userTableView.reloadData()
    }
    
    @IBAction func onClickGirls(sender: AnyObject) {
        if currentFilterGender == UserConstants.Gender.FEMALE {
            return
        }
        currentFilterGender = UserConstants.Gender.FEMALE
        beginFilter()
        userTableView.reloadData()
    }
    
    @IBAction func onClickRankGirls(sender: AnyObject) {
        if currentRankFilterGender == UserConstants.Gender.FEMALE {
            return
        }
        currentRankFilterGender = UserConstants.Gender.FEMALE
        rankUserBeginFilter()
        rankingTableView.reloadData()
    }
    @IBAction func onClickBoys(sender: AnyObject) {
        if currentFilterGender == UserConstants.Gender.MALE {
            return
        }
        currentFilterGender = UserConstants.Gender.MALE
        beginFilter()
        userTableView.reloadData()
    }
    
    @IBAction func onClickRankBoys(sender: AnyObject) {
        if currentRankFilterGender == UserConstants.Gender.MALE {
            return
        }
        currentRankFilterGender = UserConstants.Gender.MALE
        rankUserBeginFilter()
        rankingTableView.reloadData()
    }
    
    @IBAction func closeRankingView(sender: AnyObject) {
        hideRankingView()
    }
    func hideRankingView() {
        if viewRanking.hidden {
            return
        }
        UIView.transitionWithView(viewRanking, duration: 0.5, options: [], animations: { _ in
            self.viewRanking.alpha = 0.0
            }, completion: {_ in
                self.viewRanking.hidden = true
        })
        UIView.transitionWithView(viewPaperScroll, duration: 0.5, options: [UIViewAnimationOptions.CurveEaseIn, UIViewAnimationOptions.TransitionCurlUp], animations: { _ in
            }, completion: nil)
    }
    func displayRankingView() {
        if !viewRanking.hidden {
            return
        }
        viewRanking.hidden = false
        viewRanking.alpha = 0.0
        UIView.transitionWithView(viewRanking, duration: 0.5, options: [], animations: { _ in
            self.viewRanking.alpha = 1.0
            }, completion: nil)
        UIView.transitionWithView(viewPaperScroll, duration: 0.5, options: [UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.TransitionCurlDown], animations: { _ in
            }, completion: {_ in
                self.rankingTableAutoRefresh()
        })
        
    }
    
    // MARK: - Life Cycle
    func initUI() {
        viewRanking.hidden = true
        viewRankButton.layer.cornerRadius = viewRankButton.frame.height * 0.5
        viewRankButton.layer.masksToBounds = true
        lblPrompt.layer.cornerRadius = 10.0
        lblPrompt.layer.masksToBounds = true
        let btns = [btnAll, btnGirls, btnBoys, btnRankBoys, btnRankGirls]
        for b in btns {
            b.layer.cornerRadius = b.frame.height * 0.5
            b.layer.masksToBounds = true
        }
        userTableView.rowHeight = UITableViewAutomaticDimension
        userTableView.estimatedRowHeight = 100
        
        
        userTableRefresher = UIRefreshControl()
        userTableRefresher.addTarget(self, action: #selector(ExSpotlightViewController.myInfoRefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        userTableView.addSubview(userTableRefresher)
        
        rankingTableRefresher = UIRefreshControl()
        rankingTableRefresher.addTarget(self, action: #selector(ExSpotlightViewController.rankContactsRefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        rankingTableView.addSubview(rankingTableRefresher)
    
        currentFilterGender = "all"
        currentRankFilterGender = "male"
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        tableAutoRefresh()
    }
    
    //MARK : - Data Query: Me 
    func myInfoRefreshSelector() {
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.whereKey(PFKey.SPOTLIGHT.USER, equalTo: PFUser.currentUser()!)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.SPOTLIGHT.USER)
        query.getFirstObjectInBackgroundWithBlock { (result:PFObject?, error:NSError?) -> Void in
            if error == nil && result != nil {
                AppData.SpotlightData.mySpotlightPFInstance = result!
                self.allContactsRefreshSelector()
            }else {
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.0, position: HRToastPositionCenterAbove)
                self.userTableRefresher!.endRefreshing()
            }
        }
    }
    
    //MARK: - Data Query: User Table
    func tableAutoRefresh() {
        userTableRefresher!.beginRefreshing()
        if userTableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.userTableView.contentOffset.y = -self.userTableRefresher!.frame.height
                }, completion: nil)
        }
        myInfoRefreshSelector()
    }
    func allContactsRefreshSelector() {
        print("Spotlight contacts begin refreshing")
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.SPOTLIGHT.IS_ON, equalTo: true)
        query.includeKey(PFKey.SPOTLIGHT.USER)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.allContactsQueryCompletionDataHandler(result: result, error: error)
            self.allContactsQueryCompletionUIHandler(error: error)
        }
    }
    
    func allContactsQueryCompletionUIHandler(error error: NSError!) {
        if error == nil {
            self.userTableRefresher!.endRefreshing()
        }else {
            self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.0, position: HRToastPositionCenterAbove)
        }
    }
    
    func allContactsQueryCompletionDataHandler(result result:[PFObject]!, error:NSError!) {
        print("Spotlight contacts query completed with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) spotlight contacts")
            
            allSpUser.removeAll(keepCapacity: true)
            for re in result {
                if let u = ExSpotlightUser(parseObject: re) {
                    allSpUser.append(u)
                }
            }
            allSpUser.sortInPlace({AppTools.compareUserIsOrderedBefore(u1: $0.contact, u2: $1.contact)})
            beginFilter()
            userTableView.reloadData()
        }else{
            print("query error: \(error)", terminator: "")
        }
    }
    
    func beginFilter() {
        //filter
        if currentFilterGender == "all" {
            filteredSpUser = allSpUser
        }else {
            filteredSpUser = allSpUser.filter({ (u:ExSpotlightUser) -> Bool in
                return u.contact.gender == self.currentFilterGender
            })
        }
        //build contacts and index adapter
        spUsers.removeAll(keepCapacity: true)
        indexList.removeAll(keepCapacity: true)
        var curIndexPivot: String = " ", curSection = -1
        for spu in filteredSpUser {
            if AppTools.getNamePivot(spu.contact.displayName) != curIndexPivot { //new index
                //append new index
                curIndexPivot = AppTools.getNamePivot(spu.contact.displayName)
                indexList.append(curIndexPivot)
                //create new section for contacts
                spUsers.append([])
                curSection += 1
            }
            spUsers[curSection].append(spu)
        }
    }
    
    //MARK: - Data Query: Ranking Table
    func rankingTableAutoRefresh() {
        rankingTableRefresher!.beginRefreshing()
        if rankingTableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.rankingTableView.contentOffset.y = -self.rankingTableRefresher!.frame.height
                }, completion: nil)
        }
        rankContactsRefreshSelector()
    }

    func rankContactsRefreshSelector() {
        print("Ranking contacts begin refreshing")
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.SPOTLIGHT.IS_ON, equalTo: true)
        query.includeKey(PFKey.SPOTLIGHT.USER)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.rankContactsQueryCompletionDataHandler(result: result, error: error)
            self.rankContactsQueryCompletionUIHandler(error: error)
        }
    }
    
    func rankContactsQueryCompletionUIHandler(error error: NSError!) {
        rankingTableRefresher!.endRefreshing()
    }
    
    func rankContactsQueryCompletionDataHandler(result result:[PFObject]!, error:NSError!) {
        print("Ranking contacts query completed with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) ranking contacts")
            
            allRankSpUser.removeAll(keepCapacity: true)
            for re in result {
                if let u = ExSpotlightUser(parseObject: re) {
                    allRankSpUser.append(u)
                }
            }
            allRankSpUser.sortInPlace({ (u1:ExSpotlightUser, u2:ExSpotlightUser) -> Bool in
                return u1.scores > u2.scores
            })
            rankUserBeginFilter()
            rankingTableView.reloadData()
        }else{
            print("query error: \(error)", terminator: "")
        }
    }
    
    func rankUserBeginFilter() {
        filteredRankSpUser = allRankSpUser.filter({ (u:ExSpotlightUser) -> Bool in
                return (u.contact.gender == self.currentRankFilterGender) && (u.scores != 0)
        })
    }

    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == userTableView {
            return spUsers.count
        }else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == userTableView {
            return spUsers[section].count
        }else {
            return 10
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == userTableView {
            return indexList[section]
        }else {
            return nil
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if tableView == userTableView {
            return indexList
        }else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == userTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_userCell, forIndexPath: indexPath) as! ExSpotlightUserCell
            cell.initWithSpotlightUser(spUsers[indexPath.section][indexPath.row], fromParentVC:self, fromTableView: tableView, forIndexPath: indexPath)
            return cell
        }else {//ranking tableview
            
            if indexPath.row < filteredRankSpUser.count {
                let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_rankingCell, forIndexPath: indexPath) as! ExRankTableViewCell
                cell.initWithSpotlightUser(filteredRankSpUser[indexPath.row], ranking: indexPath.row + 1, fromTableView: tableView, forIndexPath: indexPath)
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_rankingPlaceholderCell, forIndexPath: indexPath) as! ExRankingPlaceholderCell
                cell.initWithRank(indexPath.row + 1)
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ExSpotlightUserCell {
            AppFunc.displayUserInfo(cell.childSpUser.contact.PFInstance, fromVC: self)
        }else if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ExRankTableViewCell {
            AppFunc.displayUserInfo(cell.childSpUser.contact.PFInstance, fromVC: self)
        }
    }

}
