//
//  UserLabel.swift
//  Duke CSA
//
//  Created by Zhe Wang on 5/5/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//
//  Subclass of UILabel with clickable author name and reply-to name.

class UserLabel: PPLabel, PPLabelDelegate {
    
    var highLightedRange:NSRange = NSMakeRange(NSNotFound, 0)
    var authorNameRange:NSRange = NSMakeRange(NSNotFound, 0)
    var replyToNameRange:NSRange = NSMakeRange(NSNotFound, 0)
    
    var author:PFUser!
    var replyTo:PFUser!
    var mainPost:String!
    
    weak var parentVC:UIViewController!
    
    var fontSize:CGFloat = 14.0
    
    func initLabel(author au:PFUser, fontSize:CGFloat, fromVC:UIViewController){
        self.fontSize = fontSize
        initLabel(author: au, replyToUser: nil, withPost: nil, fromVC: fromVC)
    }
    
    func initLabel(author au:PFUser, post:String, fromVC:UIViewController){
        initLabel(author: au, replyToUser: nil, withPost: post, fromVC: fromVC)
    }

    func initLabel(author au:PFUser, replyToUser:PFUser?, withPost:String?, fromVC:UIViewController){
        self.delegate = self
        author = au
        replyTo = replyToUser
        mainPost = withPost
        parentVC = fromVC
        
        let attrPlain = [NSFontAttributeName:UIFont.systemFontOfSize(fontSize)]
        let attrUsername = [NSFontAttributeName:UIFont.systemFontOfSize(fontSize),
            NSForegroundColorAttributeName:AppConstants.Color.usernameColor]
        let attrTxt = NSMutableAttributedString()
        
        //author
        if let auName = author[PFKey.USER.DISPLAY_NAME] as? String{
            authorNameRange.location = 0
            authorNameRange.length = auName.characters.count
            attrTxt.appendAttributedString(NSAttributedString(string: auName, attributes: attrUsername))
        }else{
            authorNameRange.location = NSNotFound
        }
        
        //replyTo - remember to check nil
        if let reName = replyToUser?[PFKey.USER.DISPLAY_NAME] as? String {
            let symbol = " @ "
            attrTxt.appendAttributedString(NSAttributedString(string: symbol, attributes: attrPlain))
            replyToNameRange.location = authorNameRange.location + authorNameRange.length + symbol.characters.count
            replyToNameRange.length = reName.characters.count
            attrTxt.appendAttributedString(NSAttributedString(string: reName, attributes: attrUsername))
        }else{
            replyToNameRange.location = NSNotFound
        }
        
        //mainPost - remember to check nil
        if let post = mainPost {
            attrTxt.appendAttributedString(NSAttributedString(string: ": \(post)", attributes: attrPlain))
        }
        
        self.attributedText = attrTxt
    }
    
    // MARK: - Delegate
    func label(label: PPLabel!, didBeginTouch touch: UITouch!, onCharacterAtIndex charIndex: CFIndex) -> Bool {
        return highlightWordContainingCharacterAtIndex(charIndex)
    }
    
    func label(label: PPLabel!, didMoveTouch touch: UITouch!, onCharacterAtIndex charIndex: CFIndex) -> Bool {
        //return highlightWordContainingCharacterAtIndex(charIndex)
        return true
    }
    
    func label(label: PPLabel!, didEndTouch touch: UITouch!, onCharacterAtIndex charIndex: CFIndex) -> Bool {
        //removeHighlight()
        return false
    }
    
    func label(label: PPLabel!, didCancelTouch touch: UITouch!) -> Bool {
        //removeHighlight()
        return false
    }
    
    
    func highlightWordContainingCharacterAtIndex(charIndex:CFIndex) -> Bool {
        
        var preventPropagateTouchToSuperView = false
        
        if charIndex == NSNotFound {
            return preventPropagateTouchToSuperView
        }
        
       // _ = NSString(string: self.attributedText!.string)
        
        highLightedRange.location = NSNotFound
        var userSelected:PFUser! = nil
        
        //check if click is on author/replyTo
        if authorNameRange.location != NSNotFound && NSLocationInRange(charIndex, authorNameRange) {
            print("author name clicked")
            highLightedRange = authorNameRange
            userSelected = author
            preventPropagateTouchToSuperView = true
        }else if replyToNameRange.location != NSNotFound && NSLocationInRange(charIndex, replyToNameRange) {
            print("replyTo name clicked")
            highLightedRange = replyToNameRange
            userSelected = replyTo
            preventPropagateTouchToSuperView = true
        }
        
        if highLightedRange.location != NSNotFound {
            let attrStr = self.attributedText!.mutableCopy() as! NSMutableAttributedString
            attrStr.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: highLightedRange)
            self.attributedText = attrStr
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "displayUserInfo:", userInfo: userSelected, repeats: false)
        }
        return preventPropagateTouchToSuperView
    }
    
    func displayUserInfo(timer:NSTimer){
        removeHighlight()
        AppFunc.displayUserInfo(timer.userInfo as! PFUser, fromVC: parentVC)
    }
    
    func removeHighlight() {
        if highLightedRange.location != NSNotFound {
            let attrStr = self.attributedText!.mutableCopy() as! NSMutableAttributedString
            attrStr.removeAttribute(NSBackgroundColorAttributeName, range: highLightedRange)
            self.attributedText = attrStr
        }
        highLightedRange = NSMakeRange(NSNotFound, 0)
    }
    
}
