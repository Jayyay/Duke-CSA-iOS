//
//  QAComposeController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/24/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAComposeAnswerController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var contentTextView: UITextView!
    
    let PLACEHOLDER_ANSWER_CONTENT: String = "Let me tell you..."
    
    var validContent = false
    
    var postConnectSuccess = false
    var postAllowed = true
    
    let TIME_OUT_IN_SEC: NSTimeInterval = 5.0
    
    var firstTimeLayingOut = true
    var composeInput: ComposeKeyboardView!
    
    var newPost: QAPost!
    
    var scrollToY:CGFloat = 0
    
    @IBAction func onPost(sender: AnyObject) {
        if !postAllowed{
            return
        }
        
        self.view.endEditing(true)
        if (!validateInput()) {
            return
        }
        
        newPost.content = contentTextView.text
        newPost.question = AppData.QAData.selectedQAQuestion.PFInstance
        
        //change app status
        postConnectSuccess = false
        postAllowed = true
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out
        NSTimer.scheduledTimerWithTimeInterval(TIME_OUT_IN_SEC, target: self, selector: #selector(postTimeOut), userInfo: nil, repeats: false)
        
        //post
        newPost.saveWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            
            //case handle
            if success{
                AppStatus.QAStatus.tableShouldRefresh = true
                self.cleanPostView(true)
            } else {
                self.view.makeToast(message: "Failed to post. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
        
        if (!AppData.QAData.selectedQAQuestion.answers.contains(newPost.PFInstance)) {
            AppData.QAData.selectedQAQuestion.answers.append(newPost.PFInstance)
        }
        AppData.QAData.selectedQAQuestion.saveWithBlock { (sucess: Bool, error: NSError?) in
            if let error = error {
                print("error saving answer to question: \(error)")
            }
        }
    }
    
    func validateInput() -> Bool{
        validContent = contentTextView.text! != PLACEHOLDER_ANSWER_CONTENT
        
        if !validContent {
            self.view.makeToast(message: "Details Needed", duration: 1.0, position: HRToastPositionCenterAbove)
            return false
        }
        return true
    }
    
    func postTimeOut() {
        if !postConnectSuccess{
            print("Post time out")
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: "Connecting timed out, job sended into background. Please wait.", duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }
    
    //// MARK: - text delegate
    //textview
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == PLACEHOLDER_ANSWER_CONTENT {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            textView.text = PLACEHOLDER_ANSWER_CONTENT
            textView.textColor = AppConstants.Color.placeholder
        }
    }
    
    func cleanPostView(shouldPop:Bool){
        contentTextView.text = nil
        validContent = false
        
        if shouldPop {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad - QAComposeAnswerViewController ")
        contentTextView.delegate = self
        
        initUI()
        initAnswerContent()
    }
    
    override func viewWillLayoutSubviews() {
        if (firstTimeLayingOut) {
            keyboardInputViewInit()
            firstTimeLayingOut = false
        }
    }
    
    func initUI() {
        registerForKeyboardNotifications()
        contentTextView.textContainerInset = UIEdgeInsetsMake(10,20,10,20);
    }
    
    // MARK: - Keyboard
    func dismissKeyboard() {
        contentTextView.endEditing(true)
    }

    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QAComposeAnswerController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QAComposeAnswerController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: Init and Life Cycle
    func keyboardInputViewInit(){
        let nib = UINib(nibName: "ComposeKeyboardView", bundle: nil)
        composeInput = nib.instantiateWithOwner(self, options: nil)[0] as! ComposeKeyboardView
        composeInput.parentTextView = self.contentTextView
        composeInput.frame = CGRectMake(0, self.view.bounds.height, self.view.bounds.width, 35)
        composeInput.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(composeInput)
        composeInput.hidden = true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        composeInput.hidden = false
        composeInput.frame.origin.y = keyboardRect.origin.y - composeInput.bounds.height - 64
        contentTextView.textContainerInset = UIEdgeInsetsMake(10,20,keyboardRect.height - 64 + composeInput.bounds.height,20)
        contentTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardRect.height - 44 + composeInput.bounds.height, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        composeInput.hidden = true
        composeInput.frame.origin.y = self.view.frame.height
        contentTextView.textContainerInset = UIEdgeInsetsMake(10, 20, 10, 20)
        contentTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func initAnswerContent() {
        if let ans = AppData.QAData.myAnswer {
            newPost = ans
            contentTextView.text = ans.content
            contentTextView.textColor = UIColor.blackColor()
            AppData.QAData.myAnswer = nil
        } else {
            newPost = QAPost(type: PFKey.QA.TYPE.ANSWER)
            contentTextView.text = PLACEHOLDER_ANSWER_CONTENT
        }
    }
    
    deinit{
        print("Release - QAComposeAnswerViewController")
    }
}
