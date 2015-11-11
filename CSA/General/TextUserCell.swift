//
//  TextUserCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 5/13/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class TextUserCell: UITableViewCell {

    var childUser:PFUser!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNetID: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMajor: UILabel!
    
    func initWithUser(u:PFUser){
        childUser = u
        lblName.text = (u[PFKey.USER.DISPLAY_NAME] as! String)
        lblNetID.text = (u[PFKey.USER.NET_ID] as! String)
        lblYear.text = AppTools.capitalizeFirstLetter(u[PFKey.USER.WHICH_YEAR] as! String)
        lblMajor.text = (u[PFKey.USER.MAJOR] as! String)
    }
    
}
