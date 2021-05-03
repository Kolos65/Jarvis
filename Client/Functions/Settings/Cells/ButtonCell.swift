//
//  ButtonCell.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import ClosureLayout
import UIKit

class ButtonCell: UITableViewCell {
    
    private lazy var button = Button()
    
    var title: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
    
    var style: Button.Style {
        get {
            return button.style
        }
        set {
            button.style = newValue
        }
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        button.addTarget(target, action: action, for: event)
    }
    
    // MARK: - Initial Setup
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        let insets = UIEdgeInsets(top: 20, left: 50, bottom: 0, right: 50)
        contentView.fillWith(button, insets: insets)
        button.layout {
            $0.height == 50
        }
    }
    
    // MARK: - Actions
    @objc
    func switchChanged() {
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
}
