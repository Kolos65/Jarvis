//
//  UIButtonExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2020. 03. 17..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit

extension UIButton {
    var imagePadding: CGFloat {
        set {
            contentEdgeInsets.right += newValue
            titleEdgeInsets.left = newValue
            titleEdgeInsets.right = -newValue
        }
        get {
            return imageEdgeInsets.left
        }
    }
    
    convenience init(
        title: String? = nil,
        backgroundColor: UIColor? = nil,
        image: UIImage? = nil,
        imagePadding: CGFloat? = nil,
        tintColor: UIColor? = nil,
        titleColor: UIColor? = nil,
        font: UIFont? = nil,
        target: Any? = nil,
        action: Selector? = nil) {
        
        self.init()
        
        if let title = title {
            self.setTitle(title, for: .normal)
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let image = image {
            self.setImage(image, for: .normal)
        }
        if let imagePadding = imagePadding {
            self.imagePadding = imagePadding
        }
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        if let titleColor = titleColor {
            self.setTitleColor(titleColor, for: .normal)
        }
        if let font = font {
            self.titleLabel?.font = font
        }
        if let action = action, let target = target {
            self.addTarget(target, action: action, for: .touchUpInside)
        }
    }
}
