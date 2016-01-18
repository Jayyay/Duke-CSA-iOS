//
//  EventDiscussViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/17/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

var kbInput:KeyboardInputView!

class EventDiscussViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, ENSideMenuDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtviewPost: UITextView!
    @IBOutlet weak var btnPost: UIButton!
    
    
    let ReuseID_DiscussCell = "IDDiscussCell"
    let ReuseID_LikeCell = "IDLikeCell"
    let ReuseID_ReplyCell = "IDReplyCell"
    let ReuseID_PaddingCell = "IDPaddingCell"
    let timeoutInSec:NSTimeInterval = 5.0
    
    var tableRefresher:UIRefreshControl!
    var scrollToY:CGFloat = 0
    
    var selectedEvent:Event!
    var discussions:[Discussion] = []
    
    var kbInputViewNeeded = false
    var queryCompletionCounter:Int = 0
    var postConnectSuccess = false
    var postAllowed = true
    
    // MARK: - IBAction
    @IBAction func onPost(sender: AnyObject) {
        if !postAllowed{
            return
        }
        txtviewPost.resignFirstResponder()
        
        //check string
        if !AppTools.stringIsValid(txtviewPost.text){return}
        
        //create new parse object
        let newDis = PFObject(className: PFKey.EVENT.DIS.CLASSKEY)
        newDis[PFKey.IS_VALID] = true
        newDis[PFKey.EVENT.DIS.PARENT] = selectedEvent.PFInstance
        newDis[PFKey.EVENT.DIS.AUTHOR] = PFUser.currentUser()
        newDis[PFKey.EVENT.DIS.MAIN_POST] = txtviewPost.text
        newDis[PFKey.EVENT.DIS.LIKES] = []
        newDis[PFKey.EVENT.DIS.REPLIES] = []
        
        //change app status
        postConnectSuccess = false
        postAllowed = true
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(timeoutInSec, target: self, selector: Selector("postTimeOut"), userInfo: nil, repeats: false)
        newDis.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            
            //case handle
            if success{
                self.txtviewPost.text = ""
                self.view.makeToast(message: "Succeeded", duration: 0.5, position: HRToastPositionCenterAbove)
                self.discussRefreshSelector()
            }else{
                self.view.makeToast(message: "Eh..Failed to post. Please try again later :(", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func postTimeOut() {
        if !postConnectSuccess{
            print("Post time out")
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: "Connecting time out, job sended into background. Please wait.", duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }
    
    
    // MARK: - Init
    func keyboardInputViewInit(){
        let nib = UINib(nibName: "KeyboardInputViewNib", bundle: nil)
        kbInput = nib.instantiateWithOwner(self, options: nil)[0] as! KeyboardInputView
        kbInput.frame = CGRectMake(0, self.view.bounds.height, self.view.bounds.width, 49)
        kbInput.txtview.delegate = self
        kbInput.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(kbInput)
        kbInput.hidden = false
        print("fffff\(kbInput.frame)")
    }
    
    func initUI() {
        txtviewPost.delegate = self
        txtviewPost.layer.borderColor = UIColor.blackColor().CGColor
        txtviewPost.layer.borderWidth = 0.5
        txtviewPost.layer.cornerRadius = 2
        txtviewPost.layer.masksToBounds = true
        txtviewPost.scrollRangeToVisible(NSMakeRange(0, 0))
        
        btnPost.layer.cornerRadius = 5.0
        btnPost.layer.masksToBounds = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        tableRefresher = UIRefreshControl()
        tableRefresher.addTarget(self, action: Selector("discussRefreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
        registerForKeyboardNotifications()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedEvent = AppData.EventData.selectedEvent
        AppData.EventData.discussVC = self
        print("viewDidLoad - EventDiscussViewController")
        initUI()
        discussTableAutoRefresh()
    }
    
    var firstTimeLayingOut: Bool = true
    override func viewWillLayoutSubviews() {
        if firstTimeLayingOut {
            keyboardInputViewInit()
            firstTimeLayingOut = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.EventStatus.currentlyDisplayedView = AppStatus.EventStatus.ViewName.Discuss
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.EventStatus.ViewName.Discuss.rawValue)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    deinit{
        print("Release - EventDiscussViewController")
    }
    
    // MARK: - Data Query
    func discussTableAutoRefresh(){
        tableRefresher.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.tableRefresher.frame.height
                }, completion: nil)
        }
        discussRefreshSelectorCacheFirst()
    }
    
    func discussRefreshSelector() {
        print("Discussion Begin Refreshing")
        let query = PFQuery(className: PFKey.EVENT.DIS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.EVENT.DIS.PARENT, equalTo: selectedEvent.PFInstance)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.EVENT.DIS.PARENT)
        query.includeKey(PFKey.EVENT.DIS.AUTHOR)
        query.includeKey(PFKey.EVENT.DIS.LIKES)
        query.includeKey("\(PFKey.EVENT.DIS.REPLIES).\(PFKey.EVENT.DIS.RE.AUTHOR)")
        query.includeKey("\(PFKey.EVENT.DIS.REPLIES).\(PFKey.EVENT.DIS.RE.REPLY_TO)")
        queryCompletionCounter = 2
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        }
    }
    
    func discussRefreshSelectorCacheFirst() {
        print("Discussion Begin Refreshing Cache First")
        let query = PFQuery(className: PFKey.EVENT.DIS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.whereKey(PFKey.EVENT.DIS.PARENT, equalTo: selectedEvent.PFInstance)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.EVENT.DIS.PARENT)
        query.includeKey(PFKey.EVENT.DIS.AUTHOR)
        query.includeKey(PFKey.EVENT.DIS.LIKES)
        query.includeKey("\(PFKey.EVENT.DIS.REPLIES).\(PFKey.EVENT.DIS.RE.AUTHOR)")
        query.includeKey("\(PFKey.EVENT.DIS.REPLIES).\(PFKey.EVENT.DIS.RE.REPLY_TO)")
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.queryCompletionCounter = 0
        query.findObjectsInBackgroundWithBlock { (result:[AnyObject]?, error:NSError?) -> Void in
            self.queryCompletionCounter++
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        }
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {
            //self.view.makeToast(message: "Fetching discussions", duration: 1.0, position: HRToastPositionCenterAbove)
            return
        }
        if self.queryCompletionCounter >= 2 {
            tableRefresher.endRefreshing()
            if error == nil{
                //self.view.makeToast(message: "Refresh succeeded", duration: 0.5, position: HRToastPositionCenterAbove)
            }else{
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result:[AnyObject]!, error:NSError!) {
        print("Discussion query completed with: ", terminator: "")
        if error == nil && result != nil{
            print("success!")
            discussions.removeAll(keepCapacity: true)
            print("Find \(result.count) results.")
            for re in (result as! [PFObject]){
                if let newDis = Discussion(parseObject: re){
                    discussions.append(newDis)
                }
            }
            tableView.reloadData()
        }else{
            print("query error: \(error)", terminator: "")
        }
    }
    
    // MARK: - Customs
    
    //could be 1.up-called from within discuss cell (when click reply), or 2.select some row and reply to it
    func replyPressed(scrollTo scrollTo:CGFloat){
        scrollToY = scrollTo
        kbInputViewNeeded = true
        kbInput.txtview.becomeFirstResponder() //this leads to keyboardWillShow getting called
        kbInput.hidden = false
    }
    
    //uitextview for posting a new discussion
    func textViewDidBeginEditing(textView: UITextView) {
        kbInputViewNeeded = false
        kbInput.hidden = true
    }
    
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if kbInputViewNeeded {
            let info : NSDictionary = notification.userInfo!
            let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
            kbInput.hidden = false
            kbInput.frame.origin.y = keyboardRect.origin.y - kbInput.frame.height - 64
            let y = scrollToY - (self.view.frame.height - keyboardRect.height - kbInput.frame.height - 64)
            if y > -tableRefresher.frame.height {
                self.tableView.setContentOffset(CGPointMake(0, y), animated: true)
            }
        }
    }
    
    func keyboardWillHide (notification:NSNotification) {
        kbInput.frame.origin.y = self.view.frame.height
        kbInput.hidden = true
    }
    
    func onDeleteReply(deleteReply:Reply, forDis:Discussion, section:NSIndexSet) {
        let str = "Delete this reply?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { _ in
            deleteReply.PFInstance[PFKey.IS_VALID] = false
            deleteReply.PFInstance.saveInBackground()
            if let i = forDis.replies.indexOf(deleteReply) {
                forDis.replies.removeAtIndex(i)
                let reArr = forDis.PFInstance[PFKey.EVENT.DIS.REPLIES] as! [PFObject]
                for re in reArr {
                    if re.objectId == deleteReply.PFInstance.objectId {
                        forDis.PFInstance.removeObject(re, forKey: PFKey.EVENT.DIS.REPLIES)
                        break
                    }
                }
                forDis.PFInstance.saveInBackground()
                self.tableView.reloadSections(section, withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return discussions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let r = discussions[section].replies.count
        let l = discussions[section].likes.count == 0 ? 0 : 1
        return r == 0 && l == 0 ? 1 : l+r+2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //main post cell
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_DiscussCell, forIndexPath: indexPath) as! EventDiscussCell
            cell.initWithDiscussion(discussions[indexPath.section], fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
            cell.imgCommentBubble.hidden = (discussions[indexPath.section].likes.count == 0 && discussions[indexPath.section].replies.count == 0)
            return cell
        }
        //like cell
        if indexPath.row == 1 && discussions[indexPath.section].likes.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_LikeCell, forIndexPath: indexPath) as! EventLikeCell
            cell.initWithLikeArray(discussions[indexPath.section].likes, fromVC: self)
            //check if separator needed
            cell.viewSeparator.hidden = discussions[indexPath.section].replies.count <= 0
            return cell
        }
        //reply cell
        if discussions[indexPath.section].likes.count == 0 { //condition: no like cell
            if indexPath.row <= discussions[indexPath.section].replies.count {
                let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_ReplyCell, forIndexPath: indexPath) as! EventReplyCell
                let re = discussions[indexPath.section].replies[indexPath.row - 1]
                cell.initWithReply(re, fromVC:self)
                return cell
            }
        }else{ //condition: like cell exists
            if indexPath.row <= discussions[indexPath.section].replies.count + 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_ReplyCell, forIndexPath: indexPath) as! EventReplyCell
                let re = discussions[indexPath.section].replies[indexPath.row - 2]
                cell.initWithReply(re, fromVC:self)
                return cell
            }
        }
        //padding cell
        return tableView.dequeueReusableCellWithIdentifier(ReuseID_PaddingCell, forIndexPath: indexPath) 
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //only the reply cell is clickable
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? EventReplyCell{
            //1.click on user's own post, ask for deletion.
            if cell.childReply.author.objectId == PFUser.currentUser()!.objectId {
                onDeleteReply(cell.childReply, forDis:discussions[indexPath.section], section: NSIndexSet(index: indexPath.section))
                return
            }
            
            //2.reply to other reply
            kbInput.txtview.delegate = cell
            kbInput.hidden = false
            replyPressed(scrollTo: cell.frame.maxY)
        }
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuShouldOpenSideMenu() -> Bool {
        return true
    }
    
}
