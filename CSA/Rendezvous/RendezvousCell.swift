//
//  RendezvousCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/23/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class RendezvousCell: UITableViewCell {
    
    @IBOutlet weak var lblAuthor: UserLabel!
    @IBOutlet weak var lblPostTime: UILabel!
    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var lblRsTitle: UILabel!
    @IBOutlet weak var lblRsWhenWhere: UILabel!
    @IBOutlet weak var lblMainPost: UILabel!
    
    @IBOutlet weak var lblTag1: UILabel!
    @IBOutlet weak var lblTag2: UILabel!
    @IBOutlet weak var lblTag3: UILabel!
    @IBOutlet weak var lblTag4: UILabel!
    @IBOutlet weak var lblTag5: UILabel!
    
    @IBOutlet weak var lblGoing: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    
    @IBOutlet weak var btnGoing: UIButton! //not used
    @IBOutlet weak var btnLike: UIButton! //not used
    @IBOutlet weak var btnReply: UIButton!
    
    @IBOutlet weak var ctRsTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var ctRsTitleTop: NSLayoutConstraint!
    @IBOutlet weak var ctRsWhenHeight: NSLayoutConstraint!
    @IBOutlet weak var ctRsWhenTop: NSLayoutConstraint!
    
    
    weak var parentVC:UIViewController!
    var childRs:Rendezvous!
    var lblTagsArr:[UILabel]!
    
    var didGo:Bool = false{
        willSet{
            childRs.IdidGo = newValue
            if newValue == false { //not going.
                lblGoing.text = "  Going (\(childRs.countGoings))"
            } else {//Is Going
                lblGoing.text = "✓ Going (\(childRs.countGoings))"
            }
        }
    }
    var didLike:Bool = false{
        willSet{
            childRs.IdidLike = newValue
            if newValue == false { //not like.
                lblLike.text = "  Like (\(childRs.countLikes))"
            }else{//like
                lblLike.text = "♡ Like (\(childRs.countLikes))"
            }
        }
    }
    
    
    
    @IBAction func onGoing(sender: AnyObject) {
        if didGo == false { //change to 'going'
            childRs.goings.append(PFUser.currentUser()!)
            let message = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) will go to your rendezvous: \(childRs.mainPost.truncate(20))."
            let sendToUser = childRs.author
            childRs.saveWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.childRs.countGoings += 1
                    self.didGo = true
                    //push notif
                    AppNotif.pushNotification(forType: AppNotif.NotifType.NEW_RS_GOING, withMessage: message, toUser: sendToUser, withSoundName: AppConstants.SoundFile.NOTIF_1, PFInstanceID: self.childRs.PFInstance.objectId!)
                }
            })
            
        }else{//change to 'not going'
            let goArr = childRs.goings
            for go in goArr {
                if go.objectId! == PFUser.currentUser()!.objectId! {
                    childRs.goings.removeAtIndex(goArr.indexOf(go)!)
                    break
                }
            }
            childRs.saveWithBlock({ (success: Bool, error: NSError?) in
                self.childRs.countGoings -= 1
                self.didGo = false
            })
        }
        //childRs.refreshGoingsNeeded = true
    }
    
    @IBAction func onLike(sender: AnyObject) {
        if didLike == false { //change to 'like'
            
            childRs.likes.append(PFUser.currentUser()!)
            //push notif
            let sendToUser = childRs.author
            let message = "\(PFUser.currentUser()![PFKey.USER.DISPLAY_NAME] as! String) likes your rendezvous: \(childRs.mainPost.truncate(20))."
            childRs.saveWithBlock({ (success:Bool, error:NSError?) -> Void in
                if let error = error {
                    print("Error liking rendezvou: ", error)
                }
                if success {
                    self.childRs.countLikes += 1
                    self.didLike = true
                    AppNotif.pushNotification(forType: AppNotif.NotifType.NEW_RS_LIKE, withMessage: message, toUser: sendToUser, withSoundName: AppConstants.SoundFile.NOTIF_1, PFInstanceID: self.childRs.PFInstance.objectId!)
                }
            })
        } else {//change to 'not like'
            let likeArr = childRs.likes
            for like in likeArr {
                if like.objectId! == PFUser.currentUser()!.objectId! {
                    childRs.likes.removeAtIndex(likeArr.indexOf(like)!)
                    break;
                }
            }
            childRs.saveWithBlock({ (success: Bool, error: NSError?) in
                self.childRs.countLikes -= 1
                self.didLike = false
            })
        }
    }
    
    @IBAction func onDelete(sender: AnyObject) {
        if let rsVC = parentVC as? RendezvousViewController {
            let str = "Delete this rendezvous?"
            let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { _ in
                self.childRs.PFInstance[PFKey.IS_VALID] = false
                self.childRs.PFInstance.saveInBackground()
                if let i = rsVC.rdzvs.indexOf(self.childRs) {
                    rsVC.rdzvs.removeAtIndex(i)
                    rsVC.beginFilter()
                    rsVC.tableView.reloadData()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            rsVC.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*note the button in rendezvous table is disabled,
     so this action can and must only be called in comment view
     */
    @IBAction func onReply(sender: AnyObject) {
        if let replyVC = parentVC as? RsReplyViewController {
            replyVC.replyPressed(scrollTo:self.frame.maxY, replyTo: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
        
        lblTagsArr = [lblTag1, lblTag2, lblTag3, lblTag4, lblTag5]
        for label in lblTagsArr {
            label.layer.cornerRadius = 5//label.frame.height * 0.5
            label.layer.masksToBounds = true
            //label.backgroundColor = UIColor
        }
    }
    
    func initWithRs(rs:Rendezvous, fromVC:UIViewController, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath) {
        childRs = rs
        self.parentVC = fromVC
        
        AppFunc.downloadPropicFromParse(user: childRs.author, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        
        //required
        lblAuthor.initLabel(author: childRs.author, fontSize: 17, fromVC: parentVC)
        lblPostTime.text = AppTools.formatDateUserFriendly(childRs.postTime)
        lblMainPost.text = childRs.mainPost
        
        //optional
        if let title = childRs.title {
            ctRsTitleHeight.constant = 26
            ctRsTitleTop.constant = 8
            lblRsTitle.hidden = false
            lblRsTitle.text = title
        }else{
            ctRsTitleHeight.constant = 0
            ctRsTitleTop.constant = 0
            lblRsTitle.hidden = true
        }
        if let ww = childRs.whenWhere {
            ctRsWhenHeight.constant = 22
            ctRsWhenTop.constant = 2
            lblRsWhenWhere.hidden = false
            lblRsWhenWhere.text = ww
        }else{
            ctRsWhenHeight.constant = 0
            ctRsWhenTop.constant = 0
            lblRsWhenWhere.hidden = true
        }
        
        //tags
        for i in 0..<childRs.tags.count {
            let tagStr = childRs.tags[i]
            lblTagsArr[i].text = tagStr
            let (R, G, B) = RsTag.colorDict[tagStr]!
            lblTagsArr[i].backgroundColor = UIColor(red: R/255, green: G/255, blue: B/255, alpha: 1.0)
            lblTagsArr[i].hidden = false
        }
        for i in 0..<lblTagsArr.count {
            lblTagsArr[i].hidden = true
        }
        
        didGo = childRs.IdidGo
        didLike = childRs.IdidLike
        
        lblReply.text = "✎  (\(childRs.countReplies))"
        btnReply.userInteractionEnabled = parentVC is RsReplyViewController
        
        //delete button
        if parentVC is RsReplyViewController || childRs.author.objectId != PFUser.currentUser()!.objectId {
            btnDelete.hidden = true
        }else{
            self.btnDelete.hidden = false
        }
        layoutIfNeeded()
    }
    
}
