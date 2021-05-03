//
//  ButtonViewModel.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import Foundation

struct ButtonViewModel: SettingsViewModel {
    var title: String
    var style: Button.Style
    var selector: Selector
}
