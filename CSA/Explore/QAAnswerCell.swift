//
//  QAAnswerCell.swift
//  Duke CSA
//
//  Created by Bill Yu on 6/27/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class QAAnswerCell: UITableViewCell {
    
    @IBOutlet weak var authorLabel: UserLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var mainPostLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var propicImageView: UIImageView!
    
    weak var parentVC: UIViewController!
    var childQA: QAPost!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
