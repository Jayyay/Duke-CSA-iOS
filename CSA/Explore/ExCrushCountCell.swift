//
//  ExCrushCountCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 1/14/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class ExCrushCountCell: UITableViewCell {

    @IBOutlet weak var lblCrushCount: UILabel!
    
    func initWithCount(n:Int) {
        lblCrushCount.text = "Number of people who have crushes on you: \(n)"
    }

}
