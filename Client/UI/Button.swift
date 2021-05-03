//
//  Button.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 16..
//

import UIKit

class Button: UIButton {
    enum Style {
        case normal
        case destructive
        case white
        case whiteDestrictive
    }
    
    var style: Style = .normal {
        didSet {
            setup()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setup()
        setTitle(title, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        Theme.register(self, selector: #selector(themeChanged))
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Theme.register(self, selector: #selector(themeChanged))
        setup()
    }
    
    @objc
    func themeChanged() {
        setup()
    }
    
    
    private func setup() {
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        layerCornerRadius = 15
        switch style {
        case .normal:
            backgroundColor = .buttonBackground
            setTitleColor(.buttonText, for: .normal)
        case .destructive:
            backgroundColor = .destructiveBackground
            setTitleColor(.destructiveText, for: .normal)
        case .white:
            backgroundColor = .white
            setTitleColor(.buttonText, for: .normal)
        case .whiteDestrictive:
            backgroundColor = .white
            setTitleColor(.destructiveText, for: .normal)
        }
    }
}
