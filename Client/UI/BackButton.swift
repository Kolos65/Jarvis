//
//  BackButton.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 16..
//

import UIKit

class BackButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setup()
        setTitle(title, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setTitle("Vissza", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        setTitleColor(UIColor(0x007AFF), for: .normal)
        setImage(UIImage(named: "left_arrow"), for: .normal)
        imagePadding = 6
        tintColor = UIColor(0x007AFF)
    }
}
