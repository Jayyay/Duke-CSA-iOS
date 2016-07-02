//
//  ComposeKeyboardController.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/2/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation

protocol QAComposeDelegate {
    func keyboardInputViewInit()
    func keyboardWillShow(notification: NSNotification)
    func keyboardWillHide(notification: NSNotification)
}

class ComposeKeyboardController: QAComposeDelegate {
    var composeInput: ComposeKeyboardView!
    var childViewController: UIViewController!
    var contentTextView: UITextView!
    
    init(childViewController: UIViewController, contentTextView: UITextView) {
        self.childViewController = childViewController
        self.contentTextView = contentTextView
    }
    
    func keyboardInputViewInit(){
        let nib = UINib(nibName: "ComposeKeyboardView", bundle: nil)
        composeInput = nib.instantiateWithOwner(self.childViewController, options: nil)[0] as! ComposeKeyboardView
        composeInput.parentTextView = self.contentTextView
        composeInput.frame = CGRectMake(0, self.childViewController.view.bounds.height, self.childViewController.view.bounds.width, 35)
        composeInput.translatesAutoresizingMaskIntoConstraints = true
        self.childViewController.view.addSubview(composeInput)
        composeInput.hidden = true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardRect = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        composeInput.hidden = false
        composeInput.frame.origin.y = keyboardRect.origin.y - composeInput.bounds.height - 64
        contentTextView.textContainerInset = UIEdgeInsetsMake(10,20, keyboardRect.height - 64 + composeInput.bounds.height,20)
        contentTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardRect.height - 44 + composeInput.bounds.height, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        composeInput.hidden = true
        composeInput.frame.origin.y = self.childViewController.view.frame.height
        contentTextView.textContainerInset = UIEdgeInsetsMake(10, 20, 10, 20)
        contentTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
