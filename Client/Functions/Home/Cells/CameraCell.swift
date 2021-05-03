//
//  CameraCell.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 15..
//

import ClosureLayout
import UIKit

class CameraCell: UITableViewCell {
    // MARK: - Contants
    private enum Constants {
        static let imageSize = CGSize(width: 75, height: 70)
        static let imageRadius: CGFloat = 16
    }
    
    // MARK: - UI Properties
    lazy var cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layout {
            $0.height == Constants.imageSize.height
            $0.width == Constants.imageSize.width
        }
        imageView.layer.cornerRadius = Constants.imageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.jarvisYellow.cgColor
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textColor
        label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    lazy var arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "right_arrow")
        imageView.tintColor = .thirdText
        imageView.layout {
            $0.width == 14
            $0.height == 25
        }
        return imageView
    }()
    
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
        contentView.layer.cornerRadius = 22
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.axis = .vertical
        titleStackView.alignment = .top
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 3
        
        contentView.addSubview(cameraImageView)
        cameraImageView.layout {
            $0.leading == contentView.leadingAnchor + 16
            $0.top == contentView.topAnchor + 15
            $0.bottom == contentView.bottomAnchor - 15
        }
        
        contentView.addSubview(titleStackView)
        titleStackView.layout {
            $0.leading == cameraImageView.trailingAnchor + 10
            $0.centerY == cameraImageView.centerYAnchor
        }
        
        contentView.addSubview(arrowIcon)
        arrowIcon.layout {
            $0.centerY == contentView.centerYAnchor
            $0.trailing == contentView.trailingAnchor - 20
        }
        
        Theme.register(self, selector: #selector(themeChanged))
    }
    
    @objc func themeChanged() {
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .secondaryText
        contentView.backgroundColor = .cardBackground
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        contentView.backgroundColor = highlighted ? UIColor.cardBackground.withAlphaComponent(0.5) : .cardBackground
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
}
