//
//  HomeCoordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 15..
//

import UIKit

protocol HomeCoordinator: ChildCoordinator {
    func navigateToCameraDetail()
    func navigateToLogin()
    func navigateBack()
    func navigateToEvents()
}

class HomeCoordinatorImpl: NSObject, HomeCoordinator {
    
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
        let viewController = HomeViewController.instantiate(from: Storyboards.home)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    // MARK: Home Coordinator Conform
    func navigateToCameraDetail() {
        let detail = CameraDetailViewController.instantiate(from: Storyboards.home)
        detail.coordinator = self
        detail.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(detail, animated: true)
    }
    
    func navigateToLogin() {
        let loginCoordinator: LoginCoordinator = LoginCoordinatorImpl(navigationController: navigationController)
        loginCoordinator.parentCoordinator = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func navigateToEvents() {
        guard let tabCoord = parentCoordinator as? TabBarCoordinator else {
            return
        }
        tabCoord.navigateTo(item: .events)
    }
}

