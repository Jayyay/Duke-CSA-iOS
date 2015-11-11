//
//  ProfilePickerViewController.swift
//  Duke CSA
//
//  Created by Zhe Wang on 6/15/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ProfilePickerViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pkvPicker: UIPickerView!
    @IBOutlet weak var dpkDatePicker: UIDatePicker!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var btnNotShow: UIButton!

    var dateMode = false
    var titleStr = ""
    var valueStr = ""
    var pickerType = 0 //gender(0), which-year(1), relationship(2)
    var lblParent:UILabel!
    
    let pickerViewTitles = [/*0*/[UserConstants.Gender.MALE, UserConstants.Gender.FEMALE, UserConstants.Gender.OTHER],
        /*1*/[UserConstants.WhichYear.FRESHMAN, UserConstants.WhichYear.SOPHOMORE, UserConstants.WhichYear.JUNIOR, UserConstants.WhichYear.SENIOR, UserConstants.WhichYear.ANCESTOR],
        /*2*/[UserConstants.Relationship.SINGLE, UserConstants.Relationship.IN_LOVE, UserConstants.Relationship.UNKNOWN]]
    
    func initWithMode(dateMode dateMode:Bool, title:String, pickerType:Int, parentLabel:UILabel){
        self.dateMode = dateMode
        self.titleStr = title
        self.valueStr = parentLabel.text!
        self.pickerType = pickerType
        self.lblParent = parentLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblTitle.text = titleStr
        lblValue.text = valueStr
        if dateMode {
            btnNotShow.hidden = false
            dpkDatePicker.hidden = false
            pkvPicker.hidden = true
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            if let date = formatter.dateFromString(lblValue.text!){
                dpkDatePicker.setDate(date, animated: true)
            }else{
                dpkDatePicker.setDate(formatter.dateFromString(UserConstants.Birthday.ENIAC)!, animated: true)
            }
        }else{
            btnNotShow.hidden = true
            dpkDatePicker.hidden = true
            pkvPicker.hidden = false
            pkvPicker.delegate = self
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        lblParent.text = lblValue.text
        super.viewWillDisappear(animated)
    }
    @IBAction func onDatePickerDidChange(sender: AnyObject) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        lblValue.text = formatter.stringFromDate(dpkDatePicker.date)
    }

    @IBAction func onClickNotShow(sender: AnyObject) {
        lblValue.text = UserConstants.Birthday.SECRET
    }
    
    //Picker delegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewTitles[pickerType].count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewTitles[pickerType][row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lblValue.text = pickerViewTitles[pickerType][row]
    }
    

}
