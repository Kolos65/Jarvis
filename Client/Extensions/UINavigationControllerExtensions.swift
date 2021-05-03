//
//  UINavigationControllerExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 13..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

extension UINavigationController {
    func popToViewController<T: UIViewController>(_ type: T.Type, animated: Bool) {
        guard let goalViewController = viewControllers.reversed().first(where: { $0 is T }) else {
            return
        }
        popToViewController(goalViewController, animated: animated)
    }
}
