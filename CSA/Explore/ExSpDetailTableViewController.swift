//
//  ExSpDetailTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/6/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExSpDetailTableViewController: UITableViewController {

    @IBOutlet weak var lblMyHits: UILabel!
    @IBOutlet weak var lblMyPoints: UILabel!
    @IBOutlet weak var swSetting: UISwitch!
    @IBOutlet weak var lblSwitchStatus: UILabel!
    @IBOutlet weak var lblErrorInfo: UILabel!
    
    var spotUserMe:ExSpotlightUser!
    let successColor = UIColor(red: 33/255, green: 178/255, blue: 239/255, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        lblErrorInfo.hidden = true
        refreshSelector()
    }
    
    @IBAction func onRefresh(sender: AnyObject) {
        refreshSelector()
    }
    
    func switchOnSucceed() {
        lblErrorInfo.textColor = successColor
        lblErrorInfo.hidden = false
        lblErrorInfo.text = "Success. Welcome back."
        setSwitchLabelOn(true)
    }
    func switchOffSucceed() {
        lblErrorInfo.textColor = successColor
        lblErrorInfo.hidden = false
        lblErrorInfo.text = "Success. You are no longer visible in Spotlight."
        setSwitchLabelOn(false)
    }
    func setError() {
        lblErrorInfo.textColor = UIColor.redColor()
        lblErrorInfo.hidden = false
        lblErrorInfo.text = "Error: Please check you internet connection."
    }
    func setSwitchLabelOn(on:Bool) {
        if on {
            lblSwitchStatus.text = "You are visible"
        }else {
            lblSwitchStatus.text = "You are invisible"
        }
    }
    
    @IBAction func onSwitch(sender: AnyObject) {
        if spotUserMe == nil {
            lblErrorInfo.hidden = false
            swSetting.setOn(!swSetting.on, animated: true)
            return
        }
        if swSetting.on {
            spotUserMe.PFInstance[PFKey.SPOTLIGHT.IS_ON] = true
            spotUserMe.PFInstance.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.switchOnSucceed()
                }else {
                    self.setError()
                    self.swSetting.setOn(!self.swSetting.on, animated: true)
                }
            })
        }else {
            spotUserMe.PFInstance[PFKey.SPOTLIGHT.IS_ON] = false
            spotUserMe.PFInstance.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.switchOffSucceed()
                }else {
                    self.setError()
                    self.swSetting.setOn(!self.swSetting.on, animated: true)
                }
            })
        }
    }
    func refreshSelector() {
        let query = PFQuery(className: PFKey.SPOTLIGHT.CLASSKEY)
        query.whereKey(PFKey.SPOTLIGHT.USER, equalTo: PFUser.currentUser()!)
        query.whereKey(PFKey.IS_VALID, equalTo: true)
        query.includeKey(PFKey.SPOTLIGHT.USER)
        query.getFirstObjectInBackgroundWithBlock { (result:PFObject?, error:NSError?) -> Void in
            
            if error == nil && result != nil {
                if let spMe = ExSpotlightUser(parseObject: result!) {
                    self.spotUserMe = spMe
                    self.lblMyHits.text = "\(spMe.scores)"
                    self.lblMyPoints.text = "\(spMe.points)"
                    self.swSetting.setOn(spMe.isOn, animated: false)
                    self.setSwitchLabelOn(spMe.isOn)
                }
            }
        }
    }

}
