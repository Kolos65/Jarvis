//
//  SettingsItemViewModel.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import UIKit

class SettingsItemViewModel: SettingsViewModel {
    init(config: SettingsCell.Configuration, style: SettingsCell.Style, selector: Selector, isEnabled: Bool, isOn: Bool) {
        self.config = config
        self.style = style
        self.selector = selector
        self.isEnabled = isEnabled
        self.isOn = isOn
    }
    
    var config: SettingsCell.Configuration
    var style: SettingsCell.Style
    var selector: Selector
    var isEnabled: Bool
    var isOn: Bool
}
