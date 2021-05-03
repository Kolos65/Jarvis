//
//  TabBarCoordinator.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 13..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

enum TabItem: Int {
    case home
    case events
    case settings
}

protocol TabBarCoordinator: ChildCoordinator {
    var tabBarController: TabBarController! { get }
    func navigateTo(item: TabItem)
}

class TabBarCoordinatorImpl: TabBarCoordinator {
    
    // MARK: Private Properties
    private let homeCoordinator: HomeCoordinator = HomeCoordinatorImpl(navigationController: UINavigationController())
    private let eventsCoordinator: EventsCoordinator = EventsCoordinatorImpl(navigationController: UINavigationController())
    private let settingsCoordinator: SettingsCoordinator = SettingsCoordinatorImpl(navigationController: UINavigationController())
    
    private var navigationControllers: [TabItem: UINavigationController] {[
        .home: homeCoordinator.navigationController,
        .events: eventsCoordinator.navigationController,
        .settings: settingsCoordinator.navigationController
    ]}
    
    // MARK: Child Coordinator Conform
    weak var parentCoordinator: Coordinator?
    
    // MARK: Coordinator Conform
    var navigationController: UINavigationController
    
    var childCoordinators = [ChildCoordinator]()
    
    // MARK: - Tab Bar Controller
    var tabBarController: TabBarController!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        homeCoordinator.parentCoordinator = self
        childCoordinators.append(homeCoordinator)
        
        eventsCoordinator.parentCoordinator = self
        childCoordinators.append(eventsCoordinator)
        
        settingsCoordinator.parentCoordinator = self
        childCoordinators.append(settingsCoordinator)
        
        startChildCoordinators()
        
        self.tabBarController = TabBarController(controllers: navigationControllers)
        navigationController.setViewControllers([self.tabBarController], animated: true)
    }
    
    // MARK: - Tab Bar Coordinator Conform
    func navigateTo(item: TabItem) {
        tabBarController.selectedIndex = item.rawValue
    }
    
    // MARK: Private Functions
    private func startChildCoordinators() {
        childCoordinators.forEach { $0.start() }
    }
}
