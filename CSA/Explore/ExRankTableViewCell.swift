//
//  ExRankTableViewCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 8/31/15.
//  Copyright (c) 2015 Zhe Wang. All rights reserved.
//

import UIKit

class ExRankTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPropic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    
    var childSpUser:ExSpotlightUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgPropic.layer.cornerRadius = imgPropic.frame.height * 0.5
        imgPropic.layer.masksToBounds = true
    }
    
    func initWithSpotlightUser(spUser:ExSpotlightUser, ranking:Int, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath) {
        childSpUser = spUser
        lblRank.text = "\(ranking)."
        AppFunc.downloadPropicFromParse(user: spUser.contact.PFInstance, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        lblName.text = spUser.contact.displayName
        lblScore.text = "\(spUser.scores)"
    }

}
