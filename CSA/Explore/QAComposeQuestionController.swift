//
//  QAComposeController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/24/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAComposeQuestionController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    let PLACEHOLDER_QUESTION_CONTENT: String = "Further descriptions about your question."
    
    var validTitle = false
    var validContent = false
    
    var postConnectSuccess = false
    var postAllowed = true
    
    let TIME_OUT_IN_SEC: NSTimeInterval = 5.0
    
    var newPost = QAPost(type: PFKey.QA.TYPE.QUESTION)
    
    @IBAction func onPost(sender: AnyObject) {
        if !postAllowed{
            return
        }
        
        self.view.endEditing(true)
        if (!validateInput()) {
            return
        }
        
        newPost.title = titleTextField.text
        newPost.content = contentTextView.text
        
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
                self.cleanPostView(shouldPop: true)
            } else {
                self.view.makeToast(message: "Failed to post. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func validateInput() -> Bool{
        validTitle = titleTextField.text!.characters.count > 5
        validContent = contentTextView.text! != PLACEHOLDER_QUESTION_CONTENT
        
        if !validTitle {
            self.view.makeToast(message: "Please put in a longer title", duration: 1.0, position: HRToastPositionCenterAbove)
            return false
        }
        
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
        if textView.text == PLACEHOLDER_QUESTION_CONTENT {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            textView.text = PLACEHOLDER_QUESTION_CONTENT
            textView.textColor = AppConstants.Color.placeholder
        }
    }
    
    //textfield
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cleanPostView(shouldPop shouldPop:Bool){
        titleTextField.text = nil
        contentTextView.text = nil
        
        validTitle = false
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
        print("viewDidLoad - QAComposeQuestionViewController ")
        AppData.QAData.postVC = self
        
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        initContent()
        initUI()
    }
    
    override func viewDidDisappear(animated: Bool) {
        AppData.QAData.myQuestion = nil
    }
    
    func initContent() {
        if let question = AppData.QAData.myQuestion {
            newPost = question
            self.navigationController?.navigationItem.title = "Edit Question"
            titleTextField.text = newPost.title
            contentTextView.text = newPost.content
            contentTextView.textColor = UIColor.blackColor()
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
    
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QAComposeQuestionController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QAComposeQuestionController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        contentTextView.textContainerInset = UIEdgeInsetsMake(10,20,keyboardRect.height - 24,20)
        contentTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardRect.height - 44, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        contentTextView.textContainerInset = UIEdgeInsetsMake(10, 20, 10, 20)
        contentTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    deinit{
        print("Release - RsPostViewController")
    }
}
