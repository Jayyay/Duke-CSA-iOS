//
//  ComposeKeyboardView.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/2/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class ComposeKeyboardView: UIView {
    
    @IBOutlet weak var hideKeyboardButton: UIButton!
    var parentTextView: UITextView!
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        parentTextView.endEditing(true)
        parentTextView.resignFirstResponder()
    }
    
}
