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
    }
    
    func initWithCourse(course: Course!) {
        numberLabel.text = course.number
        nameLabel.text = course.name
        semesterLabel.text = course.semester
        commentsLabel.text = course.comments
        majorLabel.text = course.major == "" ? "Secret" : course.major
    }

}
