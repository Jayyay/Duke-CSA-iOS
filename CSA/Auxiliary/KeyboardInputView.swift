//
//  KeyboardInputView.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/29/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class KeyboardInputView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var txtview: UITextView!
    
    override func awakeFromNib() {
        txtview.layer.cornerRadius = 5.0
        txtview.layer.borderColor = UIColor.blackColor().CGColor
        txtview.layer.borderWidth = 0.2
        txtview.layer.masksToBounds = true
        txtview.returnKeyType = UIReturnKeyType.Send
        txtview.enablesReturnKeyAutomatically = true
        txtview.userInteractionEnabled = true
        txtview.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    }
}
