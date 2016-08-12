//
//  String+truncate.swift
//  Duke CSA
//
//  Created by Bill Yu on 7/8/16.
//  Copyright © 2016 Zhe Wang. All rights reserved.
//

import Foundation

extension String {
    func truncate(length: Int, trailing: String? = "...") -> String {
        let replacedLineBreaks = self.stringByReplacingOccurrencesOfString("\n", withString: " ")
        if replacedLineBreaks.characters.count > length {
            return replacedLineBreaks.substringToIndex(replacedLineBreaks.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return replacedLineBreaks
        }
    }
}
