//
//  UIFontExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2020. 03. 27..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit

extension UIFont {
    static func systemItalicFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        var font = UIFont.systemFont(ofSize: size, weight: weight)
        if let dsc = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            font = UIFont(descriptor: dsc, size: 0)
        }
        return font
    }
}
