//
//  NotificationCenterExtensions.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 22..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import Foundation

extension NotificationCenter {
    func post(name: Notification.Name) {
        post(name: name, object: nil)
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        addObserver(observer, selector: selector, name: name, object: nil)
    }
}
