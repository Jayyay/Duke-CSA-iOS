//
//  ExCrushDetailViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/4/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExCrushDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl!
    let ReuseID_UserCell = "IDUserCell"
    let ReuseID_CountCell = "IDCrushCountCell"
    let ReuseID_NoCrushCell = "IDNoCrushCell"
    let ReuseID_NoMutualCell = "IDNoMutualCell"
    
    var mutualCrushArray:[PFUser] = []
    var crushToUnmark:ExCrush!
    
    @IBOutlet weak var tvInstructions: UITextView!
    
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
        tvInstructions.layer.cornerRadius = 5.0
        tvInstructions.layer.masksToBounds = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("myCrusheeRefreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        let nib = UINib(nibName: "BasicUserCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_UserCell)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        AppData.CrushData.detailVC = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableAutoRefresh()
    }
    
    deinit{
        print("Release - ExDetailCrushTableViewController")
    }
    
    func rebuildMutualCrush() {
        mutualCrushArray.removeAll(keepCapacity: true)
        print("Rebuild:")
        for crushItem in AppData.CrushData.myCrusheeArray {
            if AppData.CrushData.myCrusherDict[crushItem.crushee.objectId!] != nil{
                //this crushee has a mutual crush on current user
                print(crushItem.crushee[PFKey.USER.DISPLAY_NAME] as! String)
                mutualCrushArray.append(crushItem.crushee)
            }
        }
    }
    
    func tableAutoRefresh(){
        refreshControl!.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.refreshControl!.frame.height
                }, completion: nil)
        }
        myCrusheeRefreshSelector()
    }
    
    func myCrusheeRefreshSelector() {
        print("Crushees begin refreshing in detail view")
        let query = PFQuery(className: PFKey.CRUSH.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.CRUSH.CRUSHER, equalTo: PFUser.currentUser()!)
        query.includeKey(PFKey.CRUSH.CRUSHEE)
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                self.myCrusheeQueryCompletionDataHandler(result: result, error: error)
                self.myCrusherRefreshSelector()
            }else {
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.0, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func myCrusheeQueryCompletionDataHandler(result result:[AnyObject]!, error:NSError!) {
        print("Crushees query completed in detail view with ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) crushees")
            AppData.CrushData.myCrusheeArray.removeAll(keepCapacity: true)
            for c in result as! [PFObject] {
                if let newCrush = ExCrush(parseObject: c) {
                    AppData.CrushData.myCrusheeArray.append(newCrush)
                }
            }
            AppData.CrushData.buildMyCrusheeDict()
        }else{
            print("query error: \(error)")
        }
    }
    
    func myCrusherRefreshSelector() { //find those who have a crush on current user
        print("Crushers begin refreshing")
        let query = PFQuery(className: PFKey.CRUSH.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.whereKey(PFKey.CRUSH.CRUSHEE, equalTo: PFUser.currentUser()!)
        query.includeKey(PFKey.CRUSH.CRUSHER)
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                self.myCrusherQueryCompletionDataHandler(result: result,error: error)
                self.queryCompletionUIHandler(error: error)
            }else {
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.0, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func myCrusherQueryCompletionDataHandler(result result:[AnyObject]!, error:NSError!) {
        print("My crushers query completed with ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            print("Find \(result.count) crushers")
            AppData.CrushData.myCrusherArray.removeAll(keepCapacity: true)
            for c in result as! [PFObject] {
                if let newCrush = ExCrush(parseObject: c) {
                    AppData.CrushData.myCrusherArray.append(newCrush)
                }
            }
            AppData.CrushData.buildMyCrusherDict()
            rebuildMutualCrush()
            tableView.reloadData()
        }else{
            print("query error: \(error)")
        }
    }
    func queryCompletionUIHandler(error error: NSError!) {
        refreshControl!.endRefreshing()
    }
    
    func displayUnmarkAlertView(){
        let str = "Unmark your crush on \(crushToUnmark.crushee[PFKey.USER.DISPLAY_NAME] as! String)?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Unmark", style: UIAlertActionStyle.Default) { _ in
            self.removeCrush()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func removeCrush() {
        crushToUnmark.PFInstance[PFKey.IS_VALID] = false
        crushToUnmark.PFInstance.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success {
                self.tableAutoRefresh()
            }else{
                self.view.makeToast(message: "Failed. Please check your internet connection.", duration: 1.0, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return mutualCrushArray.count > 0 ? mutualCrushArray.count : 1
        case 2:
            return AppData.CrushData.myCrusheeArray.count > 0 ? AppData.CrushData.myCrusheeArray.count : 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Crush Count"
        case 1:
            return "Mutual Crush"
        case 2:
            return "My Crush"
        default:
            return nil
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_CountCell, forIndexPath: indexPath) as! ExCrushCountCell
            cell.initWithCount(AppData.CrushData.myCrusherArray.count)
            return cell
        case 1: //mutual
            if mutualCrushArray.count > 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_UserCell, forIndexPath: indexPath) as! BasicUserCell
                cell.initWithUser(mutualCrushArray[indexPath.row], fromTableView: tableView, forIndexPath: indexPath)
                cell.accessoryType = UITableViewCellAccessoryType.DetailButton
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            }else {
                return tableView.dequeueReusableCellWithIdentifier(ReuseID_NoMutualCell, forIndexPath: indexPath) 
            }
        default: //crush
            if AppData.CrushData.myCrusheeArray.count > 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_UserCell, forIndexPath: indexPath) as! BasicUserCell
                cell.initWithUser(AppData.CrushData.myCrusheeArray[indexPath.row].crushee, fromTableView: tableView, forIndexPath: indexPath)
                cell.accessoryType = UITableViewCellAccessoryType.DetailButton
                return cell
            }else{
                return tableView.dequeueReusableCellWithIdentifier(ReuseID_NoCrushCell, forIndexPath: indexPath) 
            }
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BasicUserCell {
            AppFunc.displayUserInfo(cell.childUser, fromVC: self)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section != 2 {
            return
        }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BasicUserCell {
            //need to check if the cell's displayed user is the actual crushee needing to be deleted
            //not gonna happen easily but just in case the underlying array is messed up.
            if cell.childUser.objectId == AppData.CrushData.myCrusheeArray[indexPath.row].crushee.objectId {
                crushToUnmark = AppData.CrushData.myCrusheeArray[indexPath.row]
                displayUnmarkAlertView()
            }
        }
    }

}
