//
//  EventCell.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 15..
//

import ClosureLayout
import UIKit

class EventCell: UITableViewCell, ThemeResponding {
    enum Style {
        case first
        case middle
        case last
    }
    
    var style: Style = .middle {
        didSet {
            var corners: CACornerMask = []
            if style == .first {
                corners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            if style == .last {
                corners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            }
            contentView.roundCorners(corners, radius: 22)
        }
    }
    
    // MARK: - Contants
    private enum Constants {
        static let imageSize = CGSize(width: 29, height: 29)
        static let imageRadius: CGFloat = 6
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
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        return label
    }()
    
    lazy var separator = UIView()
    
    
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
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.axis = .vertical
        titleStackView.alignment = .top
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 3
        
        contentView.addSubview(iconImageView)
        iconImageView.layout {
            $0.leading == contentView.leadingAnchor + 10
            $0.top == contentView.topAnchor + 15
            $0.bottom == contentView.bottomAnchor - 15
        }
        
        contentView.addSubview(titleStackView)
        titleStackView.layout {
            $0.leading == iconImageView.trailingAnchor + 10
            $0.centerY == iconImageView.centerYAnchor
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.layout {
            $0.top == contentView.topAnchor + 16
            $0.trailing == contentView.trailingAnchor - 20
        }
        
        separator.backgroundColor = .separatorColor
        contentView.addSubview(separator)
        separator.layout {
            $0.trailing == contentView.trailingAnchor
            $0.bottom == contentView.bottomAnchor
            $0.leading == contentView.leadingAnchor + 50
            $0.height == 0.35
        }
        
        Theme.register(self)
    }
    
    func themeChanged() {
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .secondaryText
        dateLabel.textColor = .secondaryText
        separator.backgroundColor = .separatorColor
        contentView.backgroundColor = .cardBackground
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
}
