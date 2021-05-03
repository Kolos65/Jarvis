//
//  Colors.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2019. 08. 22..
//

import UIKit

// MARK: Custom Colors
extension UIColor {
    static let lightGray = UIColor(0xC1C1C1)
    static let darkishGray = UIColor(0x6A6D7A)
    static let darkishGrayLighter = UIColor(0x9194A0)
    static let backgroundBlue = UIColor(0x131523)
    static let cardBlue = UIColor(0x191D28)
    static let backgroundGray = UIColor(0xEFF0F5)
    
    static let jarvisBlue = UIColor(0x2C70E4)
    static let jarvisGreen = UIColor(0x2DB150)
    static let jarvisRed = UIColor(0xFF2D55)
    static let jarvisYellow = UIColor(0xFFCC00)
    
    static let lightButtonBackground = UIColor(0xD7E0FF)//UIColor(0xECF0FF)
    static let darkButtonBackground = UIColor(0x141F45)
    // Text is jarvisBlue
    
    static let lightDestructiveBackground = UIColor(0xFEDCDC)//UIColor(0xFFECEC)
    static let darkDestructiveBackground = UIColor(0x31121E)
    static let destructiveText = UIColor(0xFF2D55)
}

// MARK: Theme Colors
extension UIColor {
    
    static var mainColor: UIColor {
        return Theme.isDefault ? .white : backgroundBlue
    }
    
    static var background: UIColor {
        return Theme.isDefault ? .backgroundGray : .backgroundBlue
    }
    
    static var secondaryText: UIColor {
        return Theme.isDefault ? darkishGray : darkishGrayLighter
    }
    
    static var thirdText: UIColor {
        return lightGray
    }
    
    static var cardBackground: UIColor {
        return Theme.isDefault ? .white : .cardBlue
    }
    
    static var buttonBackground: UIColor {
        return Theme.isDefault ? lightButtonBackground : darkButtonBackground
    }
    
    static var buttonText: UIColor {
        return jarvisBlue
    }
    
    static var destructiveBackground: UIColor {
        return Theme.isDefault ? lightDestructiveBackground : darkDestructiveBackground
    }
    
    static var textColor: UIColor {
        return Theme.isDefault ? .black : .white
    }
    
    static var separatorColor: UIColor {
        return Theme.isDefault ? UIColor(0xD7D7D7) : UIColor(0x3B3C3F)
    }
}
