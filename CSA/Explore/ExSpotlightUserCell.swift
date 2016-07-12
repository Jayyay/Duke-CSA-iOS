//
//  ExSpotlightUserCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 8/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExSpotlightUserCell: UITableViewCell {

    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var imgLiked: UIImageView!
    @IBOutlet weak var imgNotLike: UIImageView!
    
    @IBOutlet weak var imgVote0: UIImageView!
    @IBOutlet weak var imgVote0Dis: UIImageView!
    
    @IBOutlet weak var imgVote1: UIImageView!
    @IBOutlet weak var imgVote1Dis: UIImageView!
    
    @IBOutlet weak var imgVote2: UIImageView!
    @IBOutlet weak var imgVote2Dis: UIImageView!
    
    @IBOutlet weak var viewExpandButton: UIView!
    @IBOutlet weak var viewVote: UIView!
    @IBOutlet weak var ctVoteViewTrailing: NSLayoutConstraint!
    
    var childSpUser:ExSpotlightUser!
    weak var parentVC:ExSpotlightViewController?
    
    var didLike = false {
        willSet{
            imgLiked.hidden = !newValue
            imgNotLike.hidden = newValue
        }
    }
    
    var didVote0 = false {
        willSet{
            imgVote0.hidden = !newValue
            imgVote0Dis.hidden = newValue
        }
    }
    
    var didVote1 = false {
        willSet{
            imgVote1.hidden = !newValue
            imgVote1Dis.hidden = newValue
        }
    }
    
    var didVote2 = false {
        willSet{
            imgVote2.hidden = !newValue
            imgVote2Dis.hidden = newValue
        }
    }
    
    @IBAction func onDisplayVoteView(sender: AnyObject) {
        if viewVote.hidden {
            viewVote.hidden = false
            ctVoteViewTrailing.constant = 32
            viewVote.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.viewVote.layoutIfNeeded()
            })
        }else {
            ctVoteViewTrailing.constant = self.frame.width - viewExpandButton.frame.maxX - 20
            viewVote.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.viewVote.layoutIfNeeded()
                }, completion: { _ in
                    self.viewVote.hidden = true
            })
        }
    }
    
    //MARK : Trading
    func resumeSelector() {
        AppFunc.resumeApp()
        parentVC?.view.hideToastActivity()
    }
    func deductPoints(points:Int, completion:() -> ()) {
        parentVC?.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "")
        AppFunc.pauseApp()
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(ExSpotlightUserCell.resumeSelector), userInfo: nil, repeats: false)
        let spMe = AppData.SpotlightData.mySpotlightPFInstance!
        spMe.fetchInBackgroundWithBlock { (result:PFObject?, error:NSError?) -> Void in
            if error != nil {
                self.resumeSelector()
                self.parentVC?.view.makeToast(message: AppConstants.Prompt.ERROR, duration: 1.0, position: HRToastPositionCenterAbove)
            }else {
                if let balance = spMe[PFKey.SPOTLIGHT.POINTS] as? Int {
                    if balance < points {
                        self.resumeSelector()
                        self.parentVC?.view.makeToast(message: "You do not have enough points.", duration: 1.0, position: HRToastPositionCenterAbove)
                    }else {//okay to deduct points
                        spMe.incrementKey(PFKey.SPOTLIGHT.POINTS, byAmount: 0 - points)
                        spMe.saveInBackground()
                        completion()//update target user
                    }
                }else {
                    self.resumeSelector()
                    self.parentVC?.view.makeToast(message: "You do not have enough points.", duration: 1.0, position: HRToastPositionCenterAbove)
                }
            }
        }
    }
    
    @IBAction func onLike(sender: AnyObject) {
        if didLike {//cancel like
            childSpUser.PFInstance.removeObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.LIKES)
            childSpUser.PFInstance.saveInBackground()
        }else {//add like
            childSpUser.PFInstance.addUniqueObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.LIKES)
            if childSpUser.PFInstance.objectId != AppData.SpotlightData.mySpotlightPFInstance.objectId {
                childSpUser.PFInstance.incrementKey(PFKey.SPOTLIGHT.POINTS, byAmount: ExSpConstants.LIKE_HIT)
            }
            childSpUser.PFInstance.saveInBackground()
        }
        didLike = !didLike
        childSpUser.IdidLike = didLike
    }
    
    @IBAction func onFirstVote(sender: AnyObject) {
        if didVote0 {//cancel like
            childSpUser.PFInstance.removeObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.VOTE0)
            childSpUser.PFInstance.saveInBackground()
            didVote0 = false
            childSpUser.IdidVote0 = false
        }else {//add like
            let targetUser = childSpUser
            deductPoints(ExSpConstants.VOTE0_POINT) {_ in
                targetUser.PFInstance.addUniqueObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.VOTE0)
                //only other users' hit will increase your points
                if targetUser.PFInstance.objectId != AppData.SpotlightData.mySpotlightPFInstance.objectId {
                    targetUser.PFInstance.incrementKey(PFKey.SPOTLIGHT.POINTS, byAmount: ExSpConstants.VOTE0_HIT)
                }
                targetUser.PFInstance.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    self.resumeSelector()
                    if success {
                        targetUser.IdidVote0 = true
                        //need to take into account whether the cell is recycled.
                        if targetUser.PFInstance.objectId == self.childSpUser.PFInstance.objectId {//still same user
                            self.didVote0 = true
                        }
                    }else {
                        self.parentVC?.view.makeToast(message: AppConstants.Prompt.ERROR, duration: 1.0, position: HRToastPositionCenterAbove)
                    }
                })
            }
        }
    }
    
    @IBAction func onSecondVote(sender: AnyObject) {
        if didVote1 {//cancel like
            childSpUser.PFInstance.removeObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.VOTE1)
            childSpUser.PFInstance.saveInBackground()
            didVote1 = false
            childSpUser.IdidVote1 = false
        }else {//add like
            let targetUser = childSpUser
            deductPoints(ExSpConstants.VOTE1_POINT) {_ in
                targetUser.PFInstance.addUniqueObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.VOTE1)
                //only other users' hit will increase your points
                if targetUser.PFInstance.objectId != AppData.SpotlightData.mySpotlightPFInstance.objectId {
                    targetUser.PFInstance.incrementKey(PFKey.SPOTLIGHT.POINTS, byAmount: ExSpConstants.VOTE1_HIT)
                }
                targetUser.PFInstance.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    self.resumeSelector()
                    if success {
                        targetUser.IdidVote1 = true
                        //need to take into account whether the cell is recycled.
                        if targetUser.PFInstance.objectId == self.childSpUser.PFInstance.objectId {//still same user
                            self.didVote1 = true
                        }
                    }else {
                        self.parentVC?.view.makeToast(message: AppConstants.Prompt.ERROR, duration: 1.0, position: HRToastPositionCenterAbove)
                    }
                })
            }
        }
    }
    @IBAction func onThirdVote(sender: AnyObject) {
        if didVote2 {//cancel like
            childSpUser.PFInstance.removeObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.VOTE2)
            childSpUser.PFInstance.saveInBackground()
            didVote2 = false
            childSpUser.IdidVote2 = false
        }else {//add like
            let targetUser = childSpUser
            deductPoints(ExSpConstants.VOTE2_POINT) {_ in
                targetUser.PFInstance.addUniqueObject(PFUser.currentUser()!, forKey: PFKey.SPOTLIGHT.VOTE2)
                //only other users' hit will increase your points
                if targetUser.PFInstance.objectId != AppData.SpotlightData.mySpotlightPFInstance.objectId {
                    targetUser.PFInstance.incrementKey(PFKey.SPOTLIGHT.POINTS, byAmount: ExSpConstants.VOTE2_HIT)
                }
                targetUser.PFInstance.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    self.resumeSelector()
                    if success {
                        targetUser.IdidVote2 = true
                        //need to take into account whether the cell is recycled.
                        if targetUser.PFInstance.objectId == self.childSpUser.PFInstance.objectId {//still same user
                            self.didVote2 = true
                        }
                    }else {
                        self.parentVC?.view.makeToast(message: AppConstants.Prompt.ERROR, duration: 1.0, position: HRToastPositionCenterAbove)
                    }
                })
            }
        }
    }
    
    func initWithSpotlightUser(spUser:ExSpotlightUser, fromParentVC:ExSpotlightViewController, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath) {
        parentVC = fromParentVC
        childSpUser = spUser
        AppFunc.downloadPropicFromParse(user: spUser.contact.PFInstance, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        lblName.text = spUser.contact.displayName
        didLike = childSpUser.IdidLike
        didVote0 = childSpUser.IdidVote0
        didVote1 = childSpUser.IdidVote1
        didVote2 = childSpUser.IdidVote2
        viewVote.hidden = true
        ctVoteViewTrailing.constant = self.frame.width - viewExpandButton.frame.maxX - 30
        layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
        viewVote.layer.cornerRadius = viewVote.frame.height * 0.5
        viewVote.layer.masksToBounds = true
    }

}
