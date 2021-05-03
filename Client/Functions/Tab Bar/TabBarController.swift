//
//  TabBarController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 13..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    private var controllers: [TabItem: UINavigationController]

    init(controllers: [TabItem: UINavigationController]) {
        self.controllers = controllers
        super.init(nibName: nil, bundle: nil)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let homeIcon = UIImage(named: "home_tab")
        let eventsIcon = UIImage(named: "events_tab")
        let settingsIcon = UIImage(named: "settings_tab")
        
        let home = controllers[.home]!
        home.tabBarItem = UITabBarItem(title: "Home", image: homeIcon, tag: 0)
        
        let events = controllers[.events]!
        events.tabBarItem = UITabBarItem(title: "Events", image: eventsIcon, tag: 1)
        
        let settings = controllers[.settings]!
        settings.tabBarItem = UITabBarItem(title: "Egyéb", image: settingsIcon, tag: 4)
        
        setViewControllers([home, events, settings], animated: true)
        
        let appearance = tabBar.standardAppearance
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        
        tabBar.isTranslucent = false
        setupColors()
    }
    
    @objc func themeChanged() {
        setupColors()
    }
    
    private func setupColors() {
        let appearance = tabBar.standardAppearance
        
        appearance.backgroundColor = UIColor.mainColor.withAlphaComponent(0.7)
        appearance.backgroundEffect = UIBlurEffect(style: Theme.isDefault ? .light : .dark)
        
        let unselectedColor: UIColor = Theme.isDefault ? .lightGray : .darkishGray
        appearance
            .stackedLayoutAppearance
            .normal
            .iconColor = unselectedColor
        appearance
            .stackedLayoutAppearance
            .normal
            .titleTextAttributes = [.foregroundColor: unselectedColor]

        tabBar.standardAppearance = appearance
        tabBar.barTintColor = .mainColor
        tabBar.unselectedItemTintColor = Theme.isDefault ? .lightGray : .darkishGray
        tabBar.tintColor = Theme.isDefault ? .black : .white
    }
}
