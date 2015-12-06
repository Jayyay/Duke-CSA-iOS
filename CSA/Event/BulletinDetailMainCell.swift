//
//  BulletinDetailMainCell.swift
//  Duke CSA
//
//  Created by Zhe Wang on 12/5/15.
//  Copyright © 2015 Zhe Wang. All rights reserved.
//

class BulletinDetailMainCell: UITableViewCell {
    
    @IBOutlet weak var tvMainPost: UITextView!
    
    func initWithBulletin(b:Bulletin) {
        tvMainPost.text = b.detail
        layoutIfNeeded()
    }
}
