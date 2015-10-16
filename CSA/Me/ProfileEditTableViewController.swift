//
//  ProfileEditTableViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 6/15/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ProfileEditTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var tvAboutMe: UITextView!
    @IBOutlet weak var tfDisplayName: UITextField!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblBday: UILabel!
    
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var tfMajors: UITextField!
    @IBOutlet weak var tfMinors: UITextField!
    @IBOutlet weak var tfNetID: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var tfCellPhone: UITextField!
    @IBOutlet weak var lblRelationship: UILabel!
    
    @IBOutlet weak var imgCheckName: UIImageView!
    @IBOutlet weak var imgCheckMajors: UIImageView!
    @IBOutlet weak var imgCheckMinors: UIImageView!
    @IBOutlet weak var imgCheckNetID: UIImageView!
    @IBOutlet weak var imgCheckEmail: UIImageView!
    @IBOutlet weak var imgCheckCell: UIImageView!
    @IBOutlet weak var imgCheckAboutMe: UIImageView!
    
    var lblToPick:UILabel!
    var pickTitle = ""
    var pickType = 0
    var dateMode = false
    
    var editingMode:Bool = true
    var saveConnectSuccess = false
    
    var propicChanged = false
    var timeoutInSec:NSTimeInterval = 5.0
    let MAXLENGTH_NAME = 24
    
    //valid checking properties
    var nameValid = false {
        willSet{imgCheckName.hidden = !newValue}
    }
    var netIDValid = false {
        willSet{imgCheckNetID.hidden = !newValue}
    }
    var majorValid = false {
        willSet{imgCheckMajors.hidden = !newValue}
    }
    var minorValid = false {
        willSet{imgCheckMinors.hidden = !newValue}
    }
    var emailValid = false {
        willSet{imgCheckEmail.hidden = !newValue}
    }
    var cellPhoneValid = false {
        willSet{imgCheckCell.hidden = !newValue}
    }
    var aboutMeValid = false {
        willSet{imgCheckAboutMe.hidden = !newValue}
    }
    
    @IBAction func onSave(sender: AnyObject) {
        if !nameValid {
            self.view.makeToast(message: "Invalid Name", duration: 1.0, position: HRToastPositionCenterAbove)
            return
        }
        if !netIDValid {
            self.view.makeToast(message: "Invalid NetID", duration: 1.0, position: HRToastPositionCenterAbove)
            return
        }
        if !emailValid {
            self.view.makeToast(message: "Invalid Email", duration: 1.0, position: HRToastPositionCenterAbove)
            return
        }
        
        //optional
        if !majorValid {
            tfMajors.text = "-"
        }
        if !minorValid {
            tfMinors.text = "-"
        }
        if !aboutMeValid {
            tvAboutMe.text = "-"
        }
        if !cellPhoneValid {
            tfCellPhone.text = "-"
        }
        
        let u = PFUser.currentUser()!
        u[PFKey.USER.DISPLAY_NAME] = AppTools.getTrimmedString(tfDisplayName.text)
        u[PFKey.USER.GENDER] = lblGender.text
        u[PFKey.USER.BIRTHDAY] = lblBday.text
        u[PFKey.USER.WHICH_YEAR] = lblYear.text
        u[PFKey.USER.MAJOR] = tfMajors.text
        u[PFKey.USER.MINOR] = tfMinors.text
        u[PFKey.USER.NET_ID] = AppTools.getTrimmedString(tfNetID.text!.lowercaseString)
        u[PFKey.USER.EMAIL] = AppTools.getTrimmedString(tfEmail.text)
        u[PFKey.USER.CELL_PHONE] = AppTools.getTrimmedString(tfCellPhone.text)
        u[PFKey.USER.RELATIONSHIP] = lblRelationship.text
        u[PFKey.USER.ABOUT_ME] = tvAboutMe.text
        
        //change app status
        saveConnectSuccess = false
        self.view.makeToastActivity(position: HRToastPositionCenterAbove, message: "Saving...")
        AppFunc.pauseApp()
        
        //set time out
        if propicChanged {
            timeoutInSec = 15.0
        }else{
            timeoutInSec = 10.0
        }
        NSTimer.scheduledTimerWithTimeInterval(timeoutInSec, target: self, selector: Selector("saveTimeOut"), userInfo: nil, repeats: false)
        
        u.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //change app status
            self.saveConnectSuccess = true
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            if success {
                AppStatus.MeTableStatus.tableShouldRefreshLocally = true
                self.navigationController?.popViewControllerAnimated(false)
            }else{
                self.view.makeToast(message: "Failed to save. Please check your internet connection.", duration: 1.5, position: HRToastPositionCenterAbove)
            }
        }
    }
    
    func saveTimeOut() {
        if !saveConnectSuccess{
            AppFunc.resumeApp()
            self.view.hideToastActivity()
            self.view.makeToast(message: "Saving timed out, job sended into background. Please wait.", duration: 2, position: HRToastPositionCenterAbove)
        }
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        let str = "Discard all changes?"
        let alert = UIAlertController(title: nil, message: str, preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "Discard", style: UIAlertActionStyle.Default) { _ in
            self.navigationController?.popViewControllerAnimated(false)
        }
        let cancelAction = UIAlertAction(title: "Continue editing", style: UIAlertActionStyle.Cancel, handler:nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func onChoosePropic(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        let u = PFUser.currentUser()!
        let compressedImage = AppTools.compressImage(image)!
        imgPropic.image = compressedImage
        u[PFKey.USER.PROPIC_COMPRESSED] = PFFile(name: "compressedPropic.png", data: UIImagePNGRepresentation(compressedImage)!)
        //u[PFKey.USER.PROPIC_ORIGINAL] = PFFile(name: "propic.png", data: UIImagePNGRepresentation(image))
        propicChanged = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
    
    func initData() {
        propicChanged = false
        let u = PFUser.currentUser()!
        AppFunc.downloadPropicFromParse(user: u, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        tfDisplayName.text = u[PFKey.USER.DISPLAY_NAME] as? String
        lblGender.text = u[PFKey.USER.GENDER] as? String
        lblBday.text = u[PFKey.USER.BIRTHDAY] as? String
        tfNetID.text = u[PFKey.USER.NET_ID] as? String
        lblYear.text = u[PFKey.USER.WHICH_YEAR] as? String
        tfMajors.text = u[PFKey.USER.MAJOR] as? String
        tfMinors.text = u[PFKey.USER.MINOR] as? String
        tfEmail.text = u[PFKey.USER.EMAIL] as? String
        tfCellPhone.text = u[PFKey.USER.CELL_PHONE] as? String
        lblRelationship.text = u[PFKey.USER.RELATIONSHIP] as? String
        tvAboutMe.text = u[PFKey.USER.ABOUT_ME] as? String
        
        nameValid = AppTools.stringIsValid(tfDisplayName.text) && tfDisplayName.text!.characters.count <= MAXLENGTH_NAME
        majorValid = AppTools.stringIsValid(tfMajors.text)
        minorValid = AppTools.stringIsValid(tfMinors.text)
        netIDValid = AppTools.netIDIsValid(tfNetID.text)
        emailValid = AppTools.emailIsValid(tfEmail.text)
        cellPhoneValid = AppTools.stringIsValid(tfCellPhone.text)
        aboutMeValid = AppTools.stringIsValid(tvAboutMe.text)
    }
    
    func initUI(){
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
        
        tvAboutMe.layer.cornerRadius = 5
        tvAboutMe.layer.masksToBounds = true
        tvAboutMe.layer.borderColor = UIColor.lightGrayColor().CGColor
        tvAboutMe.layer.borderWidth = 0.5
        
        tfDisplayName.delegate = self
        tvAboutMe.delegate = self
        tfMajors.delegate = self
        tfMinors.delegate = self
        tfNetID.delegate = self
        tfEmail.delegate = self
        tfCellPhone.delegate = self
        
        tfDisplayName.addTarget(self, action: Selector("tfNameDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        tfMajors.addTarget(self, action: Selector("tfMajorDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        tfMinors.addTarget(self, action: Selector("tfMinorDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        tfNetID.addTarget(self, action: Selector("tfNetIDDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        tfEmail.addTarget(self, action: Selector("tfEmailDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
        tfCellPhone.addTarget(self, action: Selector("tfCellDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    
    
    //************<text delegate>************
    // textview represents only 'About Me' section. Important: Should another uitextview be added, this needs changing!
    func textViewDidChange(textView: UITextView) {
        aboutMeValid = AppTools.stringIsValid(textView.text)
    }
    
    //textfield
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func tfNameDidChange(textField:UITextField){
        nameValid = AppTools.stringIsValid(textField.text) && textField.text!.characters.count <= MAXLENGTH_NAME
    }
    
    func tfMajorDidChange(textField:UITextField){
        majorValid = AppTools.stringIsValid(textField.text)
    }
    
    func tfMinorDidChange(textField:UITextField){
        minorValid = AppTools.stringIsValid(textField.text)
    }
    
    func tfNetIDDidChange(textField:UITextField){
        netIDValid = AppTools.netIDIsValid(textField.text)
    }
    
    func tfEmailDidChange(textField:UITextField){
        emailValid = AppTools.emailIsValid(textField.text)
    }
    
    func tfCellDidChange(textField:UITextField){
        cellPhoneValid = AppTools.stringIsValid(textField.text)
    }
    //************</text delegate>************


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? ProfilePickerViewController{
            dvc.initWithMode(dateMode: dateMode, title: pickTitle, pickerType: pickType, parentLabel: lblToPick)
        }
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        return 44
    }
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        dateMode = false
        switch (indexPath.section, indexPath.row){
        case (0,2)://gender
            pickType = 0
            pickTitle = "Gender"
            lblToPick = lblGender
        case (0,3)://birthday
            dateMode = true
            pickTitle = "Birthday"
            lblToPick = lblBday
        case (1,0)://year
            pickType = 1
            pickTitle = "Year"
            lblToPick = lblYear
        case (2,1)://relationship
            pickType = 2
            pickTitle = "Relationship"
            lblToPick = lblRelationship
        default:
            break
        }
        return indexPath
    }

}
