//
//  Event.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import Foundation

struct Event: Codable {
    var type: String
    var name: String?
    var title: String
    var time: Int
}
