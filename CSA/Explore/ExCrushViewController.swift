//
//  ExCrushViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExCrushViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl!
    @IBOutlet weak var lblPrompt: UILabel!
    
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var btnGirls: UIButton!
    @IBOutlet weak var btnBoys: UIButton!
    
    var storedRightBarButtonItem:UIBarButtonItem!
    
    var crushee:PFUser!
    
    
    let filterNormalBGColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
    let filterChosenBGColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
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
    var allContactsQueryCompletionCounter = 0
    var contacts:[[ExContact]] = []
    var allCt:[ExContact] = []
    var filteredCt:[ExContact] = []
    var indexList:[String] = []
    let ReuseID_UserCell = "IDUserCell"
    let SegueID_Detail = "crushDetailSegue"
    
    @IBAction func onClickDetail(sender: AnyObject) {
        if let detailVC = AppData.CrushData.detailVC  {
            self.navigationController?.pushViewController(detailVC, animated: true)
        }else{
            self.performSegueWithIdentifier(SegueID_Detail, sender: self)
        }
    }
    
    
    @IBAction func onClickAll(sender: AnyObject) {
        if currentFilterGender == "all" {
            return
        }
        currentFilterGender = "all"
        beginFilter()
        tableView.reloadData()
    }
    
    @IBAction func onClickGirls(sender: AnyObject) {
        if currentFilterGender == UserConstants.Gender.FEMALE {
            return
        }
        currentFilterGender = UserConstants.Gender.FEMALE
        beginFilter()
        tableView.reloadData()
    }
    
    @IBAction func onClickBoys(sender: AnyObject) {
        if currentFilterGender == UserConstants.Gender.MALE {
            return
        }
        currentFilterGender = UserConstants.Gender.MALE
        beginFilter()
        tableView.reloadData()
    }
    
    
    //MARK: - Data Query
    func tableAutoRefresh() {
        refreshControl.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.refreshControl.frame.height
                }, completion: nil)
        }
        refreshSelector()
    }
    
    func refreshSelector() {//fetch user's all crushees first
        print("Crushees begin refreshing in main view")
        disableDetailButton()
        let query = PFQuery(className: PFKey.CRUSH.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.CRUSH.CRUSHER, equalTo: PFUser.currentUser()!)
        query.includeKey(PFKey.CRUSH.CRUSHEE)
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                self.crusheeQueryCompletionDataHandler(result: result,error: error)
                self.allContactsRefreshSelector()
            }else {
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.0, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func crusheeQueryCompletionDataHandler(result result:[PFObject]!, error:NSError!) {
        print("Crushees query completed in main view with ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) crushees")
            AppData.CrushData.myCrusheeArray.removeAll(keepCapacity: true)
            for c in result {
                if let newCrush = ExCrush(parseObject: c) {
                    AppData.CrushData.myCrusheeArray.append(newCrush)
                }
            }
            AppData.CrushData.buildMyCrusheeDict()
        }else{
            print("query error: \(error)")
        }
    }
    
    func allContactsRefreshSelector() { //then fetch all contacts
        print("Crush contacts begin refreshing")
        enableDetailButton()
        let query = PFUser.query()!
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.limit = 1000
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.allContactsQueryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.allContactsQueryCompletionCounter += 1
            self.allContactsQueryCompletionDataHandler(result: result, error: error)
            self.allContactsQueryCompletionUIHandler(error: error)
        }
    }
    
    func allContactsQueryCompletionUIHandler(error error: NSError!) {
        if self.allContactsQueryCompletionCounter == 1 {return}
        if self.allContactsQueryCompletionCounter >= 2 {
            refreshControl.endRefreshing()
        }
    }
    
    func allContactsQueryCompletionDataHandler(result result:[PFObject]!, error:NSError!) {
        print("Crush contacts query completed for the \(self.allContactsQueryCompletionCounter) time with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) crush contacts")
            allCt.removeAll(keepCapacity: true)
            let myId = PFUser.currentUser()!.objectId
            for re in result as! [PFUser]{
                if re.objectId != myId {
                    if let u = ExContact(user: re) {
                        allCt.append(u)
                    }
                }
            }
            allCt.sortInPlace({AppTools.compareUserIsOrderedBefore(u1: $0, u2: $1)})
            beginFilter()
            tableView.reloadData()
        }else{
            print("query error: \(error)", terminator: "")
        }
    }
    
    func beginFilter() {
        //filter
        if currentFilterGender == "all" {
            filteredCt = allCt
        }else {
            filteredCt = allCt.filter({ (ct:ExContact) -> Bool in
                return ct.PFInstance[PFKey.USER.GENDER] as! String == self.currentFilterGender
            })
        }
        //build contacts and index adapter
        contacts.removeAll(keepCapacity: true)
        indexList.removeAll(keepCapacity: true)
        var curIndexPivot: String = " ", curSection = -1
        for ct in filteredCt {
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
    }
    
    
    // MARK: - Life Cycle
    func addParticleEmitter() {
        let rect = CGRect(x: 0.0, y: -70.0, width: view.bounds.width, height: 50)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        view.layer.addSublayer(emitter)
        
        emitter.emitterShape = kCAEmitterLayerRectangle
        emitter.emitterPosition = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        emitter.emitterSize = rect.size
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "heart0.png")!.CGImage
        
        emitterCell.birthRate = 20
        emitterCell.lifetime = 20
        emitter.emitterCells = [emitterCell]
        
        emitterCell.yAcceleration = 40.0
        emitterCell.xAcceleration = 10.0
        emitterCell.velocity = 10.0
        emitterCell.emissionLongitude = CGFloat(-M_PI)
        emitterCell.velocityRange = 50.0
        emitterCell.emissionRange = CGFloat(M_PI_2)
        emitterCell.color = UIColor(red: 0.9, green: 1.0, blue: 1.0, alpha: 1.0).CGColor
        emitterCell.redRange   = 0.1
        emitterCell.greenRange = 0.1
        emitterCell.blueRange  = 0.1
        emitterCell.scale = 0.8
        emitterCell.scaleRange = 0.8
        emitterCell.scaleSpeed = -0.15
        emitterCell.alphaRange = 0.75
        emitterCell.alphaSpeed = -0.15
        emitterCell.lifetimeRange = 2.0
    }
    func initUI() {
        addParticleEmitter()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66
        
        lblPrompt.layer.cornerRadius = 10.0
        lblPrompt.layer.masksToBounds = true
        let btns = [btnAll, btnGirls, btnBoys]
        for b in btns {
            b.layer.cornerRadius = b.frame.height * 0.5
            b.layer.masksToBounds = true
        }
        
        storedRightBarButtonItem = self.navigationItem.rightBarButtonItem!
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ExCrushViewController.refreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        let nib = UINib(nibName: "BasicUserCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_UserCell)
        
        currentFilterGender = "all"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        tableAutoRefresh()
    }
    
    deinit{
        AppData.CrushData.wipeCrushData()
        print("Release - ExCrushTableViewController")
    }
    
    func enableDetailButton() {
        self.navigationItem.rightBarButtonItem = storedRightBarButtonItem
    }
    
    func disableDetailButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func displayMarkAlertView(){
        let str = "Mark your crush on \(crushee[PFKey.USER.DISPLAY_NAME] as! String)?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Mark", style: UIAlertActionStyle.Default) { _ in
            self.addCrush()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addCrush() {
        if AppData.CrushData.myCrusheeDict[crushee.objectId!] != nil {
            self.view.makeToast(message: "You have already marked this crush. Keep calm and wish for the best.", duration: 1.5, position: HRToastPositionCenterAbove)
        }else {
            let newCrush = PFObject(className: PFKey.CRUSH.CLASSKEY)
            newCrush[PFKey.IS_VALID] = true
            newCrush[PFKey.CRUSH.CRUSHER] = PFUser.currentUser()!
            newCrush[PFKey.CRUSH.CRUSHEE] = crushee!
            let curCrushee = crushee!
            newCrush.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    AppData.CrushData.myCrusheeArray.append(ExCrush(parseObject: newCrush)!)
                    AppData.CrushData.buildMyCrusheeDict()
                    self.view.makeToast(message: "Succeeded.", duration: 0.5, position: HRToastPositionCenterAbove)
                    //handle mutual crush
                    /*
                    if let val = AppData.CrushData.crusherDict[curCrushee.objectId!] {
                    self.handleMutualCrush(curCrushee)
                    }else {
                    
                    }*/
                    //check for mutual crush
                    let mutualCrushQuery = PFQuery(className: PFKey.CRUSH.CLASSKEY)
                    mutualCrushQuery.whereKey(PFKey.IS_VALID, equalTo: true)
                    mutualCrushQuery.whereKey(PFKey.CRUSH.CRUSHER, equalTo: curCrushee)
                    mutualCrushQuery.whereKey(PFKey.CRUSH.CRUSHEE, equalTo: PFUser.currentUser()!)
                    mutualCrushQuery.countObjectsInBackgroundWithBlock({ (result:Int32, error:NSError?) -> Void in
                        if error == nil {
                            if result > 0 {
                                self.handleMutualCrush(curCrushee)
                            }
                        }
                    })
                    
                }else {
                    self.view.makeToast(message: "Failed. Please check your internet connection.", duration: 1.0, position: HRToastPositionCenterAbove)
                }
            })
        }
    }
    
    func handleMutualCrush(lover:PFUser) {
        //push notification for the other one.
        let messageForLover = "Breaking news. \(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) has a crush on you as well."
        AppNotif.pushNotification(forType: AppNotif.NotifType.MUTUAL_CRUSH, withMessage: messageForLover, toUser: lover, withSoundName: AppConstants.SoundFile.NOTIF_1, PFInstanceID: "")
        //display an alertview for userself
        let messageForSelf = "Breaking news. \(lover[PFKey.USER.DISPLAY_NAME] as! String) has a crush on you as well."
        let alert = UIAlertController(title: nil, message: messageForSelf, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts[section].count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_UserCell, forIndexPath: indexPath) as! BasicUserCell
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        cell.initWithUser(contacts[indexPath.section][indexPath.row].PFInstance, fromTableView: tableView, forIndexPath: indexPath)
        return cell
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexList[section]
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexList
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicUserCell
        AppFunc.displayUserInfo(cell.childUser, fromVC: self)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BasicUserCell
        crushee = cell.childUser
        displayMarkAlertView()
    }


}
