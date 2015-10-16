//
//  LikesLabel.swift
//  Duke CSA
//
//  Created by Zhe Wang on 7/16/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

class LikesLabel: PPLabel, PPLabelDelegate {
    
    var highLightedRange:NSRange = NSMakeRange(NSNotFound, 0)
    var nameRanges:[(NSRange, PFUser)] = []
    var users:[PFUser]!
    
    weak var parentVC:UIViewController!
    
    var fontSize:CGFloat = 14.0
    
    func initLabel(likes likes:[PFUser], fromVC:UIViewController){
        if likes.count <= 0 {
            return
        }
        self.delegate = self
        users = likes
        parentVC = fromVC
        
        let attrPlain = [NSFontAttributeName:UIFont.systemFontOfSize(fontSize)]
        let attrUsername = [NSFontAttributeName:UIFont.systemFontOfSize(fontSize),
            NSForegroundColorAttributeName:AppConstants.Color.usernameColor]
        let attrTxt = NSMutableAttributedString()
        
        let likeSymbol = "♡ "
        attrTxt.appendAttributedString(NSAttributedString(string: likeSymbol , attributes: attrPlain))
        
        var location = likeSymbol.characters.count //starting point
        nameRanges = []
        let seperator = ", "
        for var i = 0; i < users.count; i++ {
            if let name = (users[i])[PFKey.USER.DISPLAY_NAME] as? String {
                let range = NSMakeRange(location, name.characters.count)
                nameRanges += [(range, users[i])]
                attrTxt.appendAttributedString(NSAttributedString(string: name, attributes: attrUsername))
                location += name.characters.count
                if (i + 1) < users.count {//add a comma
                    attrTxt.appendAttributedString(NSAttributedString(string: seperator, attributes: attrPlain))
                    location += seperator.characters.count
                }
            }
        }
        
        self.attributedText = attrTxt
    }
    
    //********************<Delegate>********************
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
        
        //_ = NSString(string: self.attributedText!.string)
        
        highLightedRange.location = NSNotFound
        var userSelected:PFUser! = nil
        
        //check if click is on any user
        for (r, u) in nameRanges {
            if NSLocationInRange(charIndex, r) {
                print("user name clicked")
                highLightedRange = r
                userSelected = u
                preventPropagateTouchToSuperView = true
                break
            }
        }
        
        if highLightedRange.location != NSNotFound && userSelected != nil{
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
