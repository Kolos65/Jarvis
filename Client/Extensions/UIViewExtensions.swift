//
//  UIViewExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 17..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit
import ClosureLayout

extension UIView {
    var safeAreaTop: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    func addShadow(
        withColor color: UIColor? = nil,
        offsetX: CGFloat = 0,
        offsetY: CGFloat = 14,
        opacity: Float = 0.3,
        blurRadius: CGFloat = 3.0
    ) {
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.masksToBounds = false
        layer.shadowRadius = layer.cornerRadius
        layer.shadowColor = color?.cgColor ?? layer.backgroundColor
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowOpacity = opacity
        layer.shadowPath = shadowPath.cgPath
        layer.shadowRadius = blurRadius
    }
    
    func removeShadow() {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0
        layer.shadowPath = nil
        layer.shadowRadius = 0
    }
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    @IBInspectable var layerCornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    func fillWith(blur: UIBlurEffect.Style) {
        let effect = UIBlurEffect(style: blur)
        let view = UIVisualEffectView(effect: effect)
        fillWith(view)
    }
}
