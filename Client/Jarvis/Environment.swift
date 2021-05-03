//
//  Environment.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 13..
//

import Foundation

enum Environment {
  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
  }()

  static let host: URL = {
    guard let host = Environment.infoDictionary["HOST_URL"] as? String else {
      fatalError("Please add HOST_URL to info.plist!")
    }
    guard let url = URL(string: host) else {
      fatalError("Host URL is invalid")
    }
    return url
  }()

    static let oneSignalAppId: String = {
    guard let appId = Environment.infoDictionary["ONE_SIGNAL_APP_ID"] as? String else {
      fatalError("Please add ONE_SIGNAL_APP_ID to info.plist!")
    }
    return appId
  }()
}
