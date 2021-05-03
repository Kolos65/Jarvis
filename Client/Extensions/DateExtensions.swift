//
//  DateExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2020. 02. 19..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import Foundation

extension Date {
    var year: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let str = formatter.string(from: self)
        let year = Int(str)!
        return year
    }
}
