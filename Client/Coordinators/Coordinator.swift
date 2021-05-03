//
//  Coordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 06..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [ChildCoordinator] { get set }
    
    var navigationController: UINavigationController { get set }
    
    func start()
    
    func childDidFinish(_ child: ChildCoordinator)
    
    func childDidFinish(_ child: ChildCoordinator, _ navigation: () -> Void)
}

extension Coordinator {
    func childDidFinish(_ child: ChildCoordinator) {
        childCoordinators.enumerated().forEach { (index, coordinator) in
            if coordinator === child {
                childCoordinators.remove(at: index)
            }
        }
    }
    
    func childDidFinish(_ child: ChildCoordinator, _ navigation: () -> Void) {
        navigation()
        childCoordinators.enumerated().forEach { (index, coordinator) in
            if coordinator === child {
                childCoordinators.remove(at: index)
            }
        }
    }
}
