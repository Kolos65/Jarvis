//
//  LoginCoordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 12..
//

import UIKit

protocol LoginCoordinator: ChildCoordinator {
    func loginSuccess()
}

class LoginCoordinatorImpl: LoginCoordinator {
    
    // MARK: Private Properties
    private var presentedViewControllers = [UIViewController]()
    
    // MARK: Child Coordinator Conform
    weak var parentCoordinator: Coordinator?

    // MARK: Coordinator Conform
    var navigationController: UINavigationController
    
    var childCoordinators = [ChildCoordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func start() {
        let viewController = LoginViewController.instantiate(from: Storyboards.login)
        viewController.coordinator = self
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
        presentedViewControllers.append(viewController)
    }
    
    // MARK: Login Coordinator Conform
    func loginSuccess() {
        parentCoordinator?.childDidFinish(self) {
            guard let appCoordinator = parentCoordinator as? ApplicationCoordinator else {
                // If login was presented from any vc -> Pop back to that vc
                popPresentedViewControllers()
                return
            }
            // If login was started by app coordinator -> Start app
            appCoordinator.startApp()
        }
    }
    
    // MARK: Private Functions
    private func popPresentedViewControllers() {
        let currentViewControllers = navigationController.viewControllers.reversed()
        if let goalViewController = currentViewControllers.first(where: { !presentedViewControllers.contains($0) }) {
            navigationController.popToViewController(goalViewController, animated: true)
        }
    }
}
