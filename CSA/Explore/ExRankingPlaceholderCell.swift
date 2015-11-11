//
//  ExRankingPlaceholderCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 9/3/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExRankingPlaceholderCell: UITableViewCell {

    @IBOutlet weak var lblRank: UILabel!
    
    func initWithRank(rank:Int) {
        lblRank.text = "\(rank)."
    }

}
