//
//  RsReplyViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class RsReplyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, ENSideMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let SegueID_Post = "rsPostSegue"
    let ReuseID_MainCell = "IDRsMainPostCell"
    let ReuseID_ReplyCell = "IDRsReplyCell"
    
    var selectedRs:Rendezvous!
    var kbInput:KeyboardInputView!
    var scrollToY:CGFloat = 0
    var replyToUser:PFUser?
    var replies:[RsReply] = []
    var tableRefresher:UIRefreshControl!
    var queryCompletionCounter:Int = 0
    
    var postConnectSuccess = false
    var postAllowed = true
    let timeoutInSec:NSTimeInterval = 5.0
    
    @IBAction func onClickMore(sender: AnyObject) {
        self.sideMenuController()?.sideMenu?.showSideMenu()
    }
    // MARK: Post & Delete
    func replyPressed(scrollTo scrollTo:CGFloat, replyTo:PFUser?){
        scrollToY = scrollTo
        if let r = replyTo {
            replyToUser = r
        }else {
            replyToUser = nil
        }
        kbInput.txtview.becomeFirstResponder() //this leads to keyboardWillShow getting called
    }
    
    func onSend(txt:String) { //called by pressing return key of textview.
        if !AppTools.stringIsValid(txt) {return}
        
        var FLAG_REPLY_TO = false
        //new parseObject
        let newReply = PFObject(className: PFKey.RENDEZVOUS.RE.CLASSKEY)
        newReply[PFKey.IS_VALID] = true
        newReply[PFKey.RENDEZVOUS.RE.AUTHOR] = PFUser.currentUser()
        newReply[PFKey.RENDEZVOUS.RE.PARENT] = selectedRs.PFInstance
        if let u = replyToUser {
            newReply[PFKey.RENDEZVOUS.RE.REPLY_TO] = u
            //if replyTo != author, send another notif to replyTo.
            FLAG_REPLY_TO = (u.objectId != selectedRs.author.objectId)
        }
        newReply[PFKey.RENDEZVOUS.RE.MAIN_POST] = txt
        selectedRs.PFInstance.addObject(newReply, forKey: PFKey.RENDEZVOUS.REPLIES)
        
        //change app status
        postConnectSuccess = false
        postAllowed = false
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(timeoutInSec, target: self, selector: Selector("postTimeOut"), userInfo: nil, repeats: false)
        
        //notif message
        let message = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) replied to your rendezvous."
        let sendToUser = selectedRs.author
        
        var message2:String!
        var sendToUser2:PFUser!
        if FLAG_REPLY_TO {
            message2 = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) mentioned you in a comment about a rendezvous"
            sendToUser2 = replyToUser!
        }
        
        replyToUser = nil
        
        //save in parse
        selectedRs.PFInstance.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            
            if success{
                self.kbInput.txtview.text = ""
                self.selectedRs.countReplies++
                self.replies.append(RsReply(parseObject: newReply, parentRs: self.selectedRs)!)
                self.tableView.reloadData()
                AppNotif.pushNotification(forType: AppNotif.NotifType.NEW_RS_REPLY, withMessage: message, toUser: sendToUser, withSoundName: AppConstants.SoundFile.NOTIF_1)
                if FLAG_REPLY_TO {
                    AppNotif.pushNotification(forType: AppNotif.NotifType.NEW_RS_REPLY_RE, withMessage: message2, toUser: sendToUser2, withSoundName: AppConstants.SoundFile.NOTIF_1)                }
            }else{
                self.view.makeToast(message: "Failed to reply. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
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
    
    func onDelete(deleteRe:RsReply) {
        let str = "Delete this comment?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { _ in
            deleteRe.PFInstance[PFKey.IS_VALID] = false
            deleteRe.PFInstance.saveInBackgroundWithBlock({_ -> Void in})
            if let i = self.replies.indexOf(deleteRe) {
                self.replies.removeAtIndex(i)
                self.selectedRs.countReplies = self.replies.count
                
                let reArr = self.selectedRs.PFInstance[PFKey.RENDEZVOUS.REPLIES] as! [PFObject]
                for re in reArr {
                    if re.objectId == deleteRe.PFInstance.objectId {
                        self.selectedRs.PFInstance.removeObject(re, forKey: PFKey.RENDEZVOUS.REPLIES)
                        break
                    }
                }
                self.selectedRs.PFInstance.saveInBackground()
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { _ in
        }
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Data Query
    func rsReplyAutoRefresh(){
        tableRefresher.beginRefreshing()
        if tableView.contentOffset.y == 0 {
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.tableView.contentOffset.y = -self.tableRefresher.frame.height
                }, completion: nil)
        }
        replyRefreshSelectorCacheFirst()
    }
    
    func replyRefreshSelector() {
        print("Reply Begin Refreshing")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.includeKey("\(PFKey.RENDEZVOUS.REPLIES).\(PFKey.RENDEZVOUS.RE.AUTHOR)")
        query.includeKey("\(PFKey.RENDEZVOUS.REPLIES).\(PFKey.RENDEZVOUS.RE.REPLY_TO)")
        query.cachePolicy = PFCachePolicy.NetworkOnly
        queryCompletionCounter = 2
        query.getObjectInBackgroundWithId(selectedRs.PFInstance.objectId!, block: { (result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func replyRefreshSelectorCacheFirst() {
        print("Reply Begin Refreshing")
        let query = PFQuery(className: PFKey.RENDEZVOUS.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.includeKey("\(PFKey.RENDEZVOUS.REPLIES).\(PFKey.RENDEZVOUS.RE.AUTHOR)")
        query.includeKey("\(PFKey.RENDEZVOUS.REPLIES).\(PFKey.RENDEZVOUS.RE.REPLY_TO)")
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryCompletionCounter = 0
        query.getObjectInBackgroundWithId(selectedRs.PFInstance.objectId!, block: { (result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionCounter++
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {
            return
        }
        if self.queryCompletionCounter >= 2 {
            tableRefresher.endRefreshing()
            if error != nil{
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result: PFObject!, error:NSError!) {
        print("Reply query completed with ", terminator: "")// for the \(self.queryCompletionCounter) time with: ")
        if error == nil && result != nil{
            print("success!")
            replies.removeAll(keepCapacity: true)
            print("Find \(result[PFKey.RENDEZVOUS.REPLIES]!.count) replies.")
            for re in result[PFKey.RENDEZVOUS.REPLIES] as! [PFObject]{
                if let newRe = RsReply(parseObject: re, parentRs: selectedRs) {
                    replies.append(newRe)
                }
            }
            self.selectedRs.countGoings = result[PFKey.RENDEZVOUS.GOINGS]!.count
            self.selectedRs.countLikes = result[PFKey.RENDEZVOUS.LIKES]!.count
            self.selectedRs.countReplies = replies.count
            tableView.reloadData()
        }else{
            print("query error: \(error)")
        }
    }
    //********************</Data Query>********************
    
    
    
    //********************<Keyboard>********************
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        kbInput.hidden = false
        kbInput.frame.origin.y = keyboardRect.origin.y - kbInput.frame.height
        let y = scrollToY - (UIScreen.mainScreen().bounds.height - keyboardRect.height - kbInput.frame.height)
        if y > -tableRefresher.frame.height {
            self.tableView.setContentOffset(CGPointMake(0, y), animated: true)
        }
    }
    
    func keyboardWillHide (notification:NSNotification) {
        kbInput.frame.origin.y = self.view.frame.height
        kbInput.hidden = true
    }
    
    //called everytime text is changed. Used here to detect return (send) pressed.
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            onSend(textView.text)
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    //********************</Keyboard>********************
    
    
    
    //MARK: Init and Life Cycle
    func keyboardInputViewInit(){
        let nib = UINib(nibName: "KeyboardInputViewNib", bundle: nil)
        kbInput = nib.instantiateWithOwner(self, options: nil)[0] as! KeyboardInputView
        kbInput.txtview.delegate = self
        kbInput.userInteractionEnabled = true
        kbInput.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, 50)
        kbInput.hidden = true
        self.view.addSubview(kbInput)
    }

    func initUI() {
        //tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        let nib = UINib(nibName: "RendezvousCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_MainCell)
        
        tableRefresher = UIRefreshControl()
        tableRefresher.addTarget(self, action: Selector("replyRefreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
        
        keyboardInputViewInit()
        registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        selectedRs = AppData.RendezvousData.selectedRendezvous
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        AppStatus.RendezvousStatus.currentlyDisplayedView = AppStatus.RendezvousStatus.ViewName.Reply
        self.sideMenuController()?.sideMenu?.resetMenuSelectionForRow(AppStatus.RendezvousStatus.ViewName.Reply.rawValue)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rsReplyAutoRefresh()
    }
    deinit{
        print("Release - RsDetailViewController")
    }
    
    
    //MARK: - Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count + 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_MainCell) as! RendezvousCell
            cell.initWithRs(selectedRs, fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_ReplyCell) as! RsReplyCell
            cell.initWithReply(replies[indexPath.row - 1], fromVC: self)
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 { //top cell not selectable
            return
        }
        //reply to the comment (if I'm not the author), or delete (if I'm the author)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RsReplyCell {
            if cell.childReply.author.objectId != PFUser.currentUser()!.objectId { //reply
                replyPressed(scrollTo: cell.frame.maxY, replyTo: cell.childReply.author)
            }else { //author is current user, delete
                onDelete(cell.childReply)
            }
        }
    }
    
    //MARK: - Side Menu
    func sideMenuShouldOpenSideMenu() -> Bool {
        return true
    }
    
}
