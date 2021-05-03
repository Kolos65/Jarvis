//
//  Banner.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 15..
//

import Foundation
import NotificationBannerSwift

class Banner {
    static func showError(_ message: String? = nil) {
        let banner = FloatingNotificationBanner(
            title: "Error",
            subtitle: message ?? "Something went wrong during your request, please try again later!",
            style: .danger
        )
        
        banner.show(
            edgeInsets: UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8),
            cornerRadius: 16,
            shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
            shadowBlurRadius: 16,
            shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        )
    }
    
    static func showSuccess(_ message: String? = nil) {
        let banner = FloatingNotificationBanner(
            title: "Success",
            subtitle: message ?? "The operation completed successfully!",
            style: .success
        )
        
        banner.show(
            edgeInsets: UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8),
            cornerRadius: 16,
            shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
            shadowBlurRadius: 16,
            shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        )
    }
}
