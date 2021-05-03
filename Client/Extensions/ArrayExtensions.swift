//
//  ArrayExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 12. 31..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    var indexOfMin: Int? {
        guard let min = self.min() else { return nil }
        return self.firstIndex(of: min)
    }
}

extension Array {
    mutating func compactAppend(_ newElement: Element?) {
        guard let element = newElement else { return }
        append(element)
    }
}
