//
//  AppDelegate.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 01. 13..
//

import UIKit
import OneSignal
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var coordinator: ApplicationCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: - One Signal Config
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(Environment.oneSignalAppId)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        // MARK: - Start App Coordinator
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true

        coordinator = ApplicationCoordinatorImpl(navigationController: navigationController)
        
        coordinator?.start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        let rootVC = presentedViewController(with: window?.rootViewController)
        return rootVC is CameraDetailViewController ? .allButUpsideDown : .portrait
    }
    
    private func presentedViewController(with rootViewController: UIViewController!) -> UIViewController? {
        guard let viewController = rootViewController else {
            return nil
        }
        switch viewController {
        case let vc as TabBarController:
            return presentedViewController(with: vc.selectedViewController)
        case let vc as UINavigationController:
            return presentedViewController(with: vc.visibleViewController)
        default:
            guard viewController.presentedViewController == nil else {
                return presentedViewController(with: viewController.presentedViewController)
            }
            return viewController
        }
    }
}
