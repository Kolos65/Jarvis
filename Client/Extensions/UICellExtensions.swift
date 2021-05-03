//
//  UITableViewCellExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 22..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}
