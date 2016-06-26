//
//  RsPostViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/24/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class RsPostViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, ENSideMenuDelegate {
    
    let PLACEHOLDER_FOR_TEXTVIEW:String = "Details about the rendezvous. Please remember to check the tags below."
    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfWhenWhere: UITextField!
    @IBOutlet weak var tvMainPost: UITextView!
    
    @IBOutlet weak var imgTitleCheck: UIImageView!
    @IBOutlet weak var imgWhenWhereCheck: UIImageView!
    @IBOutlet weak var imgMainCheck: UIImageView!
    @IBOutlet weak var imgTagCheck: UIImageView!

    var checkArr:[UIImageView]!
    
    @IBOutlet weak var btnTag1: UIButton!
    @IBOutlet weak var btnTag2: UIButton!
    @IBOutlet weak var btnTag3: UIButton!
    @IBOutlet weak var btnTag4: UIButton!
    @IBOutlet weak var btnTag5: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var tagArr:[UIButton]!
    var tagIsOn:[Bool] = [Bool](count:5, repeatedValue:false)
    
    var validTitle = false
    var validWhenWhere = false
    //var validWhere = false
    var validMain = false
    var validTag:Int = 0
    
    var postConnectSuccess = false
    var postAllowed = true
    
    let TIME_OUT_IN_SEC:NSTimeInterval = 5.0
    
    var scrollToY:CGFloat = 0
    
    @IBAction func onPost(sender: AnyObject) {
        
        if !postAllowed{
            return
        }
        
        self.view.endEditing(true)
        
        if !validMain {
            self.view.makeToast(message: "Details Needed", duration: 1.0, position: HRToastPositionCenterAbove)
            return
        }
        if validTag <= 0 {
            self.view.makeToast(message: "Please select at least one tag", duration: 1.0, position: HRToastPositionCenterAbove)
            return
        }
        
        let newPost = PFObject(className: PFKey.RENDEZVOUS.CLASSKEY)
        newPost[PFKey.IS_VALID] = true
        newPost[PFKey.RENDEZVOUS.AUTHOR] = PFUser.currentUser()
        
        //optionals
        if validTitle {
            newPost[PFKey.RENDEZVOUS.TITLE] = tfTitle.text
        }
        if validWhenWhere {
            newPost[PFKey.RENDEZVOUS.WHEN_WHERE] = tfWhenWhere.text
        }
        
        //main post
        newPost[PFKey.RENDEZVOUS.MAIN_POST] = tvMainPost.text
        
        //tags
        var finalTags:[String] = []
        for i in 0..<tagIsOn.count {
            if tagIsOn[i] {
                print(RsTag.tagIndexToName[i])
                finalTags.append(RsTag.tagIndexToName[i])
            }
        }
        newPost[PFKey.RENDEZVOUS.TAGS] = finalTags
        
        //init three arrays
        newPost[PFKey.RENDEZVOUS.GOINGS] = []
        newPost[PFKey.RENDEZVOUS.LIKES] = []
        newPost[PFKey.RENDEZVOUS.REPLIES] = []
        
        //change app status
        postConnectSuccess = false
        postAllowed = true
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(TIME_OUT_IN_SEC, target: self, selector: #selector(postTimeOut), userInfo: nil, repeats: false)

        //post
        newPost.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            
            //case handle
            if success{
                AppStatus.RendezvousStatus.tableShouldRefresh = true
                self.cleanPostView(shouldPop: true)
            }else{
                self.view.makeToast(message: "Failed to post. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func postTimeOut() {
        if !postConnectSuccess{
            print("Post time out")
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: "Connecting timed out, job sended into background. Please wait.", duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }
    
    @IBAction func onClickTag(sender: AnyObject) {
        let index = sender.tag - 1
        let tagChosen = tagArr[index]
        
        if tagIsOn[index]{//unchoose
            tagIsOn[index] = false
            tagChosen.backgroundColor = UIColor.whiteColor()
            validTag -= 1
            if validTag <= 0 {
                imgTagCheck.hidden = true
            }
        }else{//choose
            tagIsOn[index] = true
            let tagStr = RsTag.tagIndexToName[index]
            let (R, G, B) = RsTag.colorDict[tagStr]!
            tagChosen.backgroundColor = UIColor(red: R/255, green: G/255, blue: B/255, alpha: 1.0)
            validTag += 1
            imgTagCheck.hidden = false
        }
    }
    
    
    //// MARK: - text delegate
    //textview
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == PLACEHOLDER_FOR_TEXTVIEW {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        scrollToY = textView.frame.maxY
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if AppTools.stringIsValid(textView.text) {
            imgMainCheck.hidden = false
            validMain = true
        }else{
            imgMainCheck.hidden = true
            validMain = false
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            textView.text = PLACEHOLDER_FOR_TEXTVIEW
            textView.textColor = AppConstants.Color.placeholder
        }
    }
    //textfield
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        scrollToY = textField.frame.maxY
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tfTitleDidChange(textField:UITextField){
        if AppTools.stringIsValid(textField.text) {
            imgTitleCheck.hidden = false
            validTitle = true
        }else{
            imgTitleCheck.hidden = true
            validTitle = false
        }
    }
    
    func tfWhenDidChange(textField:UITextField){
        if AppTools.stringIsValid(textField.text) {
            imgWhenWhereCheck.hidden = false
            validWhenWhere = true
        }else{
            imgWhenWhereCheck.hidden = true
            validWhenWhere = false
        }
    }
    
    /*func tfWhereDidChange(textField:UITextField){
        if AppTools.stringIsValid(textField.text) {
            imgWhereCheck.hidden = false
            validWhere = true
        }else{
            imgWhereCheck.hidden = true
            validWhere = false
        }
    }*/
    
    func cleanPostView(shouldPop shouldPop:Bool){
        
        for check in checkArr {
            check.hidden = true
        }
        
        for i in 0 ..< tagIsOn.count {
            tagIsOn[i] = false
        }
        for t in tagArr {
            t.backgroundColor = UIColor.whiteColor()
        }
        
        tfTitle.text = nil
        tfWhenWhere.text = nil
        tvMainPost.text = nil
        
        validTitle = false
        validWhenWhere = false
        validMain = false
        validTag = 0
        
        if shouldPop {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    
    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RsPostViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        let y = scrollToY - (self.view.frame.height - keyboardRect.height)
        if y > -30 {
            self.tableView.setContentOffset(CGPointMake(0, y), animated: true)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
         self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad - RsPostViewController ")
        AppData.RendezvousData.postVC = self
        
        tfTitle.delegate = self
        tfWhenWhere.delegate = self
        tvMainPost.delegate = self
        
        tvMainPost.layer.cornerRadius = 5
        tvMainPost.layer.borderWidth = 0.5
        tvMainPost.layer.borderColor = UIColor.blackColor().CGColor
        tvMainPost.layer.masksToBounds = true
        
        tagArr = [btnTag1, btnTag2, btnTag3, btnTag4, btnTag5]
        for button in tagArr {
            button.layer.cornerRadius = button.frame.height * 0.5
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 0.5
            button.layer.masksToBounds = true
        }
        
        checkArr = [imgTitleCheck, imgWhenWhereCheck, imgMainCheck, imgTagCheck]
        for check in checkArr {
            check.hidden = true
        }
        
        tfTitle.addTarget(self, action: #selector(RsPostViewController.tfTitleDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        tfWhenWhere.addTarget(self, action: #selector(RsPostViewController.tfWhenDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        registerForKeyboardNotifications()
    }
    
    deinit{
        print("Release - RsPostViewController")
    }
    
    /*
    func simulatePost() {
        var newPost = PFObject(className: PFKey.RENDEZVOUS.CLASSKEY)
        newPost[PFKey.IS_VALID] = true
        newPost[PFKey.RENDEZVOUS.AUTHOR] = PFUser.currentUser()
        
        newPost[PFKey.RENDEZVOUS.TITLE] = "打球"
        //newPost[PFKey.RENDEZVOUS.WHEN] = "Tonight at 9:00"
        //newPost[PFKey.RENDEZVOUS.WHERE] = "Wilson"
        newPost[PFKey.RENDEZVOUS.MAIN_POST] = "Just come"
        newPost[PFKey.RENDEZVOUS.TAGS] = [RsTag.sport]
        newPost[PFKey.RENDEZVOUS.GOINGS] = [PFUser.currentUser()]
        newPost[PFKey.RENDEZVOUS.LIKES] = [PFUser.currentUser()]
        newPost[PFKey.RENDEZVOUS.REPLIES] = []
        newPost.saveInBackgroundWithBlock { _ in
        }
    }*/
    func sideMenuShouldOpenSideMenu() -> Bool {
        return false
    }
    
}
