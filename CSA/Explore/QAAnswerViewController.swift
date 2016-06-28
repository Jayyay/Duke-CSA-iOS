//
//  QAAnswerViewController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/27/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAAnswerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate {
    
    let ReuseID_QAAnswer = "QAAnswerCell"
    let ReuseID_ReplyCell = "QAReplyCell"

    @IBOutlet weak var tableView: UITableView!
    
    var selectedQA: QAPost!
    var kbInput: KeyboardInputView!
    var scrollToY: CGFloat = 0
    var replyToUser: PFUser?
    var replies: [QAReply] = []
    var tableRefresher: UIRefreshControl!
    var queryCompletionCounter: Int = 0
    
    var postConnectSuccess = false
    var postAllowed = true
    let timeoutInSec: NSTimeInterval = 5.0
    
    var lineOfText = 0
    var lastHeight = CGFloat(0)
    var firstTimeLayingOut: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedQA = AppData.QAData.selectedQAAnswer
        
        initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AppStatus.QAStatus.currentlyDisplayedView = AppStatus.QAStatus.ViewName.Reply
    }
    
    override func viewWillLayoutSubviews() {
        if firstTimeLayingOut {
            keyboardInputViewInit()
            firstTimeLayingOut = false
            print("first time laying out")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        QAReplyAutoRefresh()
    }
    
    deinit{
        print("Release - RsDetailViewController")
    }
    
    func initUI() {
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        let nib = UINib(nibName: "QAAnswerCellNib", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ReuseID_QAAnswer)
        
        tableRefresher = UIRefreshControl()
        //tableRefresher.attributedTitle = NSAttributedString(string: "Refreshing")
        tableRefresher.addTarget(self, action: #selector(QAAnswerViewController.replyRefreshSelector), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableRefresher)
        
        registerForKeyboardNotifications()
    }
    
    // MARK: - Post & Delete
    
    @IBAction func comment(sender: AnyObject) {
        replyPressed(scrollTo: 0, replyTo: nil)
    }
    
    func replyPressed(scrollTo scrollTo: CGFloat, replyTo:PFUser?){
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
        let newReply = PFObject(className: PFKey.QA.RE.CLASSKEY)
        newReply[PFKey.IS_VALID] = true
        newReply[PFKey.QA.RE.AUTHOR] = PFUser.currentUser()
        newReply[PFKey.QA.RE.PARENT] = selectedQA.PFInstance
        if let u = replyToUser {
            newReply[PFKey.QA.RE.REPLY_TO] = u
            //if replyTo != author, send another notif to replyTo.
            FLAG_REPLY_TO = (u.objectId != selectedQA.author.objectId)
        }
        newReply[PFKey.QA.RE.MAIN_POST] = txt
        selectedQA.PFInstance.addObject(newReply, forKey: PFKey.QA.REPLIES)
        
        //change app status
        postConnectSuccess = false
        postAllowed = false
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(timeoutInSec, target: self, selector: #selector(QAAnswerViewController.postTimeOut), userInfo: nil, repeats: false)
        
        //notif message
        let message = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) replied to your QA."
        let sendToUser = selectedQA.author
        
        var message2:String!
        var sendToUser2:PFUser!
        if FLAG_REPLY_TO {
            message2 = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) mentioned you in a comment about a QA"
            sendToUser2 = replyToUser!
        }
        
        replyToUser = nil
        
        //save in parse
        selectedQA.PFInstance.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            
            if success{
                self.kbInput.txtview.text = ""
                self.replies.append(QAReply(parseObject: newReply, parentQA: self.selectedQA)!)
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
    
    func onDelete(deleteRe: QAReply) {
        let str = "Delete this comment?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { _ in
            deleteRe.PFInstance[PFKey.IS_VALID] = false
            deleteRe.PFInstance.saveInBackgroundWithBlock({_ -> Void in})
            if let i = self.replies.indexOf(deleteRe) {
                self.replies.removeAtIndex(i)
                
                let reArr = self.selectedQA.PFInstance[PFKey.QA.REPLIES] as! [PFObject]
                for re in reArr {
                    if re.objectId == deleteRe.PFInstance.objectId {
                        self.selectedQA.PFInstance.removeObject(re, forKey: PFKey.QA.REPLIES)
                        break
                    }
                }
                self.selectedQA.PFInstance.saveInBackground()
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: tableview delegate and data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_QAAnswer, forIndexPath: indexPath) as! QAAnswerCell
            cell.initWithPost(selectedQA, fromVC: self, fromTableView: tableView, forIndexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(ReuseID_ReplyCell) as! QAReplyCell
            cell.initWithReply(replies[indexPath.row - 1], fromVC: self)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //reply to the comment (if I'm not the author), or delete (if I'm the author)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? QAReplyCell {
            if cell.childReply.author.objectId != PFUser.currentUser()!.objectId { //reply
                replyPressed(scrollTo: cell.frame.maxY, replyTo: cell.childReply.author)
            } else { //author is current user, delete
                onDelete(cell.childReply)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Data Query
    func QAReplyAutoRefresh(){
        /*tableRefresher.beginRefreshing()
         if tableView.contentOffset.y == 0 {
         UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
         self.tableView.contentOffset.y = -self.tableRefresher.frame.height
         }, completion: nil)
         }*/
        replyRefreshSelector()
    }
    
    func replyRefreshSelector() {
        print("Reply Begin Refreshing")
        let query = PFQuery(className: PFKey.QA.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.includeKey("\(PFKey.QA.REPLIES).\(PFKey.QA.RE.AUTHOR)")
        query.includeKey("\(PFKey.QA.REPLIES).\(PFKey.QA.RE.REPLY_TO)")
        query.cachePolicy = PFCachePolicy.NetworkOnly
        queryCompletionCounter = 2
        query.getObjectInBackgroundWithId(selectedQA.PFInstance.objectId!, block: { (result:PFObject?, error:NSError?) -> Void in
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func replyRefreshSelectorCacheFirst() {
        print("Reply Begin Refreshing")
        let query = PFQuery(className: PFKey.QA.CLASSKEY)
        query.orderByDescending(PFKey.CREATED_AT)
        query.includeKey("\(PFKey.QA.REPLIES).\(PFKey.QA.RE.AUTHOR)")
        query.includeKey("\(PFKey.QA.REPLIES).\(PFKey.QA.RE.REPLY_TO)")
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryCompletionCounter = 0
        query.getObjectInBackgroundWithId(selectedQA.PFInstance.objectId!, block: { (result: PFObject?, error: NSError?) -> Void in
            self.queryCompletionCounter += 1
            self.queryCompletionDataHandler(result: result,error: error)
            self.queryCompletionUIHandler(error: error)
        })
    }
    
    func queryCompletionUIHandler(error error: NSError!) {
        if self.queryCompletionCounter == 1 {return}
        if self.queryCompletionCounter >= 2 {
            tableRefresher.endRefreshing()
            if error != nil{
                self.view.makeToast(message: AppConstants.Prompt.REFRESH_FAILED, duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func queryCompletionDataHandler(result result: PFObject!, error: NSError!) {
        print("Reply query completed with ", terminator: "")// for the \(self.queryCompletionCounter) time with: ")
        if error == nil && result != nil{
            print("success!")
            replies.removeAll(keepCapacity: true)
            print("Find \(result[PFKey.QA.REPLIES]!.count) replies.")
            for re in result[PFKey.QA.REPLIES] as! [PFObject]{
                if let newRe = QAReply(parseObject: re, parentQA: selectedQA) {
                    replies.append(newRe)
                }
            }
            tableView.reloadData()
        } else {
            print("query error: \(error)")
        }
    }
    
    
    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QAAnswerViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QAAnswerViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        kbInput.hidden = false
        kbInput.frame.origin.y = keyboardRect.origin.y - kbInput.bounds.height - 64
        let y = scrollToY - (UIScreen.mainScreen().bounds.height - keyboardRect.height - kbInput.frame.height - 64)
        if y > 0 {
            self.tableView.setContentOffset(CGPointMake(0, y), animated: true)
        }
    }
    
    func keyboardWillHide (notification:NSNotification) {
        kbInput.frame.origin.y = self.view.frame.height
        kbInput.hidden = true
    }
    
    // resize the textview height according to user input
    // credit to Han Yu, huge thanks.
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        //textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        if (newSize.height == lastHeight) || (newSize.height > lastHeight && lineOfText >= 4) {
            // no need to resize frame
            return
        }
        lineOfText += newSize.height > lastHeight ? 1 : -1
        lastHeight = newSize.height
        if lineOfText >= 4 {
            textView.scrollEnabled = true
        }else {
            textView.scrollEnabled = false
        }
        
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        newFrame.origin.y = newFrame.origin.y - newSize.height + textView.frame.height
        
        var boxFrame = kbInput.frame
        boxFrame.origin.y = boxFrame.origin.y - newSize.height + textView.frame.height
        boxFrame.size = CGSize(width: boxFrame.width, height: newSize.height + 16)
        
        textView.frame = newFrame;
        kbInput.frame = boxFrame
        
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
    
    // MARK: scroll view delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let ttView = kbInput {
            ttView.resignFirstResponder()
            ttView.endEditing(true)
        }
    }
    
    //MARK: Init and Life Cycle
    func keyboardInputViewInit(){
        let nib = UINib(nibName: "KeyboardInputViewNib", bundle: nil)
        kbInput = nib.instantiateWithOwner(self, options: nil)[0] as! KeyboardInputView
        kbInput.frame = CGRectMake(0, self.view.bounds.height, self.view.bounds.width, 49)
        kbInput.txtview.delegate = self
        kbInput.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(kbInput)
        kbInput.hidden = true
        print("fffff\(kbInput.frame)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
