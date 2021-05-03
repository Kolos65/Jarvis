//
//  StoryboardInstantiable.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 06..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable {
    static func instantiate(from storyboardName: String) -> Self
}

extension StoryboardInstantiable where Self: UIViewController {
    static func instantiate(from storyboardName: String) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? Self else {
            fatalError("Could not instantiate view controller: \(String(describing: self)) from storyboard: \(storyboardName)")
        }
        
        return viewController
    }
}
