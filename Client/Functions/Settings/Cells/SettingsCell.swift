//
//  SettingsCell.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import ClosureLayout
import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - Contants
    private enum Constants {
        static let imageSize = CGSize(width: 29, height: 29)
        static let imageRadius: CGFloat = 6
    }
    
    // Config
    enum Style {
        case first
        case middle
        case last
        case only
    }
    
    enum Configuration {
        case recognition
        case detection
        case notification
        case darkmode
    }
    
    // MARK: - UI Properties
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layout {
            $0.height == Constants.imageSize.height
            $0.width == Constants.imageSize.width
        }
        imageView.layer.cornerRadius = Constants.imageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    
    lazy var switchButton = UISwitch()
    
    var topConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
        
    var style: Style = .middle {
        didSet {
            var corners: CACornerMask = []
            if style == .first || style == .only {
                corners = corners.union([.layerMinXMinYCorner, .layerMaxXMinYCorner])
                topConstraint?.constant = 16
            }
            if style == .last || style == .only {
                corners = corners.union([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
                bottomConstraint?.constant = -16
            }
            contentView.roundCorners(corners, radius: 14)
        }
    }
    
    var config: Configuration? {
        didSet {
            guard let config = config else { return }
            switch config {
            case .recognition:
                iconImageView.image = UIImage(named: "face_icon_filled")
                titleLabel.text = "Face recognition"
            case .detection:
                iconImageView.image = UIImage(named: "eye_icon_filled")
                titleLabel.text = "Motion detection"
            case .notification:
                iconImageView.image = UIImage(named: "push_icon_filled")
                titleLabel.text = "Notifications"
            case .darkmode:
                iconImageView.image = UIImage(named: "moon_icon_filled")
                titleLabel.text = "Darkmode"
            }
        }
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
        contentView.backgroundColor = .cardBackground

        contentView.layerCornerRadius = 14
        let views = [iconImageView, titleLabel, switchButton]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        
        let insets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        let constraints = contentView.fillWith(stackView, insets: insets)
        
        topConstraint = constraints.top
        bottomConstraint = constraints.bottom
        
        Theme.register(self, selector: #selector(themeChanged))
    }
    
    // MARK: - Actions
    @objc
    func themeChanged() {
        titleLabel.textColor = .textColor
        contentView.backgroundColor = .cardBackground
    }
    
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        switchButton.addTarget(target, action: action, for: event)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    override func setSelected(_ selected: Bool, animated: Bool) {}
}
