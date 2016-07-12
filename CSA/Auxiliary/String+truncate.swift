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
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
