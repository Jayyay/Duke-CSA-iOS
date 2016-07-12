//
//  EventReplyCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/17/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class EventReplyCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var lblReply: UserLabel!
    
    weak var parentVC:EventDiscussViewController!
    var childReply:Reply!
    
    let timeoutInSec:NSTimeInterval = 5.0
    
    var postConnectSuccess = false
    var postAllowed = true
    
    var lineOfText = 0
    var lastHeight = CGFloat(0)
    
    func initWithReply(rep:Reply, fromVC:EventDiscussViewController) {
        childReply = rep
        parentVC = fromVC
        
        /*if childReply.author.objectId == PFUser.currentUser()!.objectId {
            self.selectionStyle = UITableViewCellSelectionStyle.Gray
        }else{
            self.selectionStyle = UITableViewCellSelectionStyle.None
        }*/
        lblReply.initLabel(author: childReply.author, replyToUser:childReply.replyTo, withPost: childReply.mainPost, fromVC: parentVC)
    }
    
    //called everytime textview's text is changed. Used here to detect return (send) pressed.
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        print(textView)
        if text == "\n" {
            onPostReply(textView.text)
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == kbInput.txtview {
            print("did change ", textView.frame)
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
            } else {
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
    }
    
    func onPostReply(txt:String) {
        if !postAllowed{
            return
        }
        //check string
        if !AppTools.stringIsValid(txt) {return}
        
        //create new parse object
        let newPFReply = PFObject(className: PFKey.EVENT.DIS.RE.CLASSKEY)
        newPFReply[PFKey.IS_VALID] = true
        newPFReply[PFKey.EVENT.DIS.RE.PARENT] = childReply.parent.PFInstance
        newPFReply[PFKey.EVENT.DIS.RE.AUTHOR] = PFUser.currentUser()!
        newPFReply[PFKey.EVENT.DIS.RE.REPLY_TO] = childReply.author
        newPFReply[PFKey.EVENT.DIS.RE.MAIN_POST] = txt
        let parentDis = childReply.parent;
        parentDis.PFInstance.addObject(newPFReply, forKey: PFKey.EVENT.DIS.REPLIES)
        
        //change app status
        postConnectSuccess = false
        postAllowed = false
        parentVC.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Posting...")
        AppFunc.pauseApp()
        
        //set time out timer
        NSTimer.scheduledTimerWithTimeInterval(timeoutInSec, target: self, selector: #selector(EventReplyCell.postTimeOut), userInfo: nil, repeats: false)
        
        
        let message = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) mentioned you in a reply about the event '\(childReply.parent.parent[PFKey.EVENT.TITLE] as! String)'."
        let sendToUser = childReply.author
        
        //parse backend
        childReply.parent.PFInstance.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.postConnectSuccess = true
            self.postAllowed = true
            AppFunc.resumeApp()
            self.parentVC.view.hideToastActivity()
            
            if success{
                kbInput.txtview.text = ""
                let newRep = Reply(parseObject: newPFReply, parentDis: parentDis)!
                self.childReply.parent.replies.append(newRep)
                self.parentVC.view.makeToast(message: "Succeeded.", duration: 0.5, position: HRToastPositionCenterAbove)
                self.parentVC.tableView.reloadData()
                AppNotif.pushNotification(forType: AppNotif.NotifType.NEW_EVENT_REPLY, withMessage: message, toUser: sendToUser, withSoundName: AppConstants.SoundFile.NOTIF_1, PFInstanceID: self.childReply.parent.parent.objectId!)
            }else{
                self.parentVC.view.makeToast(message: "Failed to reply. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func postTimeOut() {
        if !postConnectSuccess{
            AppFunc.resumeApp()
            postAllowed = true
            self.parentVC.view.hideToastActivity()
            self.parentVC.view.makeToast(message: "Connecting time out, job sended into background. Please wait.", duration: 1.5, position: HRToastPositionCenterAbove)
        }
    }

    
}
