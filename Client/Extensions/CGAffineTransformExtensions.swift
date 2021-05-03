//
//  CGAffineTransformExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2020. 03. 24..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit

extension CGAffineTransform {
    public static func scale(_ scaleXY: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(scaleX: scaleXY, y: scaleXY)
    }
    
    public static func translateX(_ x: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: x, y: 0)
    }
    
    public static func translateY(_ y: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: 0, y: y)
    }
}
