//
//  UINibExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 10. 26..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

extension UINib {
    convenience init(nibName: String) {
        self.init(nibName: nibName, bundle: nil)
    }
}
