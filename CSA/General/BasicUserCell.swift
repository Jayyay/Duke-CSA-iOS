//
//  BasicUserCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 4/28/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class BasicUserCell: UITableViewCell {

    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    var childUser:PFUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
    }
    
    func initWithUser(childUser:PFUser, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath){
        self.childUser = childUser
        AppFunc.downloadPropicFromParse(user: childUser, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        lblName.text = childUser[PFKey.USER.DISPLAY_NAME] as? String
        let str = childUser[PFKey.USER.WHICH_YEAR] as! String
        lblYear.text = AppTools.capitalizeFirstLetter(str)
    }

}
