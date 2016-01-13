//
//  EventPicCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 1/13/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class EventPicCell: UITableViewCell {

    @IBOutlet weak var imgPropic: UIImageView!

    func initWithEvent(evt:Event, fromTableView tableView:UITableView, forIndexPath indexPath:NSIndexPath){
        
        if let p = evt.propic {
            AppFunc.downloadPictureFile(file: p, saveToImgView: imgPropic, inTableView: tableView, forIndexPath: indexPath)
        }
        layoutIfNeeded()
    }
}
