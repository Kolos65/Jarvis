//
//  AppCoordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 06..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit
import KeychainAccess

protocol ApplicationCoordinator: Coordinator {
    func navigateToLogin()
    func startApp()
}

class ApplicationCoordinatorImpl: ApplicationCoordinator {
    
    // MARK: Coordinator Conform
    var navigationController: UINavigationController

    var childCoordinators = [ChildCoordinator]()
    
    var keychain = Keychain()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.barStyle = Theme.isDefault ? .default : .black
    }
    
    func start() {
        keychain["token"] == nil ? navigateToLogin() : startApp()
        Theme.register(self, selector: #selector(changeStatusBarColor))
    }
    
    // MARK: Application Coordinator Conform
    func navigateToLogin() {
        let loginCoordinator: LoginCoordinator = LoginCoordinatorImpl(navigationController: navigationController)
        loginCoordinator.parentCoordinator = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    func startApp() {
        let tabBarCoordinator: TabBarCoordinator = TabBarCoordinatorImpl(navigationController: navigationController)
        tabBarCoordinator.parentCoordinator = self
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    @objc func changeStatusBarColor() {
        navigationController.navigationBar.barStyle = Theme.isDefault ? .default : .black
    }
}
