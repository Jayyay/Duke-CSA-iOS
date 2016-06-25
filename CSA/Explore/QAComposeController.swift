//
//  QAComposeController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/24/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAComposeController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    let PLACEHOLDER_FOR_TEXTVIEW: String = "Further descriptions about your question."
    
    var validTitle = false
    var validContent = false
    
    var postConnectSuccess = false
    var postAllowed = true
    
    let TIME_OUT_IN_SEC:NSTimeInterval = 5.0
    
    @IBAction func onPost(sender: AnyObject) {
        if !postAllowed{
            return
        }
        
        self.view.endEditing(true)
        validInput()
        
        let newPost = QAPost(type: PFKey.QA.CLASSKEY)
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
            }else{
                self.view.makeToast(message: "Failed to post. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func validInput() {
        validTitle = !(titleTextField.text!.characters.count < 5)
        validContent = !(contentTextView.text!.characters.count < 5)
        
        if !validTitle {
            self.view.makeToast(message: "Please put in a longer title", duration: 1.0, position: HRToastPositionCenterAbove)
        }
        
        if !validContent {
            self.view.makeToast(message: "Details Needed", duration: 1.0, position: HRToastPositionCenterAbove)
            return
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
    
    //// MARK: - text delegate
    //textview
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == PLACEHOLDER_FOR_TEXTVIEW {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            textView.text = PLACEHOLDER_FOR_TEXTVIEW
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
        print("viewDidLoad - RsPostViewController ")
        AppData.QAData.postVC = self
        
        titleTextField.delegate = self
        contentTextView.delegate = self
    }
    
    deinit{
        print("Release - RsPostViewController")
    }
}