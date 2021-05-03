//
//  IndexPathExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 12. 30..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

extension IndexPath {
    init(item: Int) {
        self.init(item: item, section: 0)
    }
    
    init(section: Int) {
        self.init(item: 0, section: section)
    }
}
