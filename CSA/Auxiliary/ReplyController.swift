//
//  ReplyController.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/28/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class ReplyController: UIViewController, UITextViewDelegate, UITableViewDelegate, UIScrollViewDelegate {
    
    var kbInput: KeyboardInputView!
    var tblView: UITableView!
    
    var lineOfText = 0
    var lastHeight = CGFloat(0)
    var firstTimeLayingOut: Bool = true
    var scrollToY: CGFloat = 0
    
    var postConnectSuccess = false
    var postAllowed = true
    let timeoutInSec: NSTimeInterval = 5.0
    
    var replyToUser: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    
    func initUI() {
        registerForKeyboardNotifications()
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
            self.tblView.setContentOffset(CGPointMake(0, y), animated: true)
        }
    }
    
    func keyboardWillHide (notification:NSNotification) {
        kbInput.frame.origin.y = self.view.frame.height
        kbInput.hidden = true
    }
    
    // resize the textview height according to user input
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
    
//    // MARK: scroll view delegate
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if let ttView = kbInput {
//            ttView.resignFirstResponder()
//            ttView.endEditing(true)
//        }
//    }
    
    // function to be overriden
    func onSend(text:String!) {
        
    }
    
    func replyPressed(scrollTo scrollTo:CGFloat, replyTo:PFUser?){
        scrollToY = scrollTo
        if let r = replyTo {
            replyToUser = r
        } else {
            replyToUser = nil
        }
        kbInput.txtview.becomeFirstResponder() //this leads to keyboardWillShow getting called
    }
    
    func postTimeOut() {
        if !postConnectSuccess{
            print("Post time out")
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: "Connecting time out, job sended into background. Please wait.", duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }

}
