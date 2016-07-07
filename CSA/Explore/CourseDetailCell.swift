//
//  CourseDetailCell.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/4/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import UIKit

class CourseDetailCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var semesterLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.preferredMaxLayoutWidth = 200
        commentsLabel.preferredMaxLayoutWidth = 300
        majorLabel.preferredMaxLayoutWidth = 200
    }
    
    func initWithCourse(course: Course!) {
        numberLabel.text = course.number
        nameLabel.text = course.name
        semesterLabel.text = course.semester
        commentsLabel.text = course.comments
        
        let majorText = NSMutableAttributedString()
        let majorHeader = NSAttributedString(string: "Commenter's Major: ", attributes: [NSForegroundColorAttributeName: AppConstants.Color.orderButton])
        let major = course.major == "" ? "Secret" : course.major
        let majorReal = NSAttributedString(string: major, attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
        majorText.appendAttributedString(majorHeader)
        majorText.appendAttributedString(majorReal)
        majorLabel.attributedText = majorText
    }

}
