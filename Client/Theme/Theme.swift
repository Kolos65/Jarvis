//
//  ThemeManager.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 22..
//  Copyright © 2019. Foltányi Kolos. All rights reserved.
//

import UIKit

@objc protocol ThemeResponding {
    @objc func themeChanged()
}

enum Theme {
    enum Style: String {
        case normal
        case dark
    }
    
    private static let key = "theme"
    
    private static var _currentStyle: Style?
    
    private static var savedStyle: Style {
        get {
            guard let styleString = UserDefaults.standard.string(forKey: key) else {
                UserDefaults.standard.set(Style.normal.rawValue, forKey: key)
                return .normal
            }
            return Style(rawValue: styleString) ?? .normal
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            NotificationCenter.default.post(name: .themeChanged)
        }
    }
    
    static var currentStyle: Style {
        get {
            guard let style = _currentStyle else {
                _currentStyle = savedStyle
                return _currentStyle!//swiftlint:disable:this force_unwrapping
            }
            return style
        }
        set {
            guard newValue != _currentStyle else { return }
            _currentStyle = newValue
            savedStyle = newValue
        }
    }
    
    static var isDefault: Bool {
        return currentStyle == .normal
    }
    
    static func change() {
        NotificationCenter.default.post(name: .themeChanged)
        currentStyle = isDefault ? .dark : .normal
    }
    
    static func register(_ object: Any, selector: Selector) {
        NotificationCenter.default.addObserver(object, selector: selector, name: .themeChanged)
    }
    
    static func register(_ object: ThemeResponding) {
        NotificationCenter.default.addObserver(object,
            selector: #selector(object.themeChanged),
            name: .themeChanged
        )
    }
}
