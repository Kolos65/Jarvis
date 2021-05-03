//
//  SettingsCoordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import UIKit

protocol SettingsCoordinator: ChildCoordinator {
    func navigateToLogin()
    func navigateBack()
}

class SettingsCoordinatorImpl: SettingsCoordinator {
    
    // MARK: Child Coordinator Conform
    weak var parentCoordinator: Coordinator?
    
    // MARK: Coordinator Conform
    var navigationController: UINavigationController
    
    var childCoordinators = [ChildCoordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        let viewController = SettingsViewController.instantiate(from: Storyboards.settings)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    // MARK: Settings Coordinator Conform
    func navigateToLogin() {
        let loginCoordinator: LoginCoordinator = LoginCoordinatorImpl(navigationController: navigationController)
        loginCoordinator.parentCoordinator = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}

