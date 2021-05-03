//
//  CameraDetailViewController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 16..
//

import KeychainAccess
import ClosureLayout
import UIKit

class CameraDetailViewController: UIViewController {
    
    // MARK: - Injected Properties
    weak var coordinator: HomeCoordinator?
    
    // MARK: - Data Source
    private var configDataSource: ConfigDataSource = ConfigRemoteDataSource()
    private lazy var token: String? = {
        let keychain = Keychain()
        return keychain["token"]
    }()
    
    // MARK: - UI Properties
    @IBOutlet weak var backButton: BackButton!
    lazy var stackView = UIStackView()
    lazy var videoImageView = VideoImageView()
    lazy var settingsStackView = UIStackView()
    lazy var resetButton = Button(title: "Reset Motion Detector")

    typealias SettingItem = (icon: UIImageView, title: UILabel, subtitle: UILabel, switch: UISwitch)
    
    lazy var faceRecItem = createSettingItem(
        iconName: "face_icon_filled",
        title: "Face recognition:",
        subtitle: "Turning off face recognition will disable unknwn face alarming."
    )
    
    lazy var motionItem = createSettingItem(
        iconName: "eye_icon_filled",
        title: "Motion detection:",
        subtitle: "Turning off motion detection will disable the alarm system."
    )
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .mainColor
        createLayout()
        setupActions()
        videoImageView.layer.masksToBounds = true
        videoImageView.contentMode = .scaleAspectFill
        videoImageView.url = Environment.host.appendingPathComponent("stream")
        guard let token = token else {
            Banner.showError()
            return
        }
        videoImageView.token = token
        videoImageView.start()
        loadConfig()
        backButton.setTitle("Home", for: .normal)
        resetButton.addTarget(self, action: #selector(resetMotion), for: .touchUpInside)
    }
    
    // MARK: - Actions
    func setupActions() {
        motionItem.switch.addTarget(self, action: #selector(turnMotion), for: .valueChanged)
        faceRecItem.switch.addTarget(self, action: #selector(turnFaceRec), for: .valueChanged)
    }
    
    func loadConfig() {
        guard let token = token else { return }
        configDataSource.getFaceRecognition(token: token) { response, error in
            guard let response = response else { return }
            self.faceRecItem.switch.isOn = response.recognizer
            self.faceRecItem.switch.isEnabled = true
        }
        
        configDataSource.getMotionDetector(token: token) { response, error in
            guard let response = response else { return }
            self.motionItem.switch.isOn = response.detector
            self.motionItem.switch.isEnabled = true
        }
    }

    @objc
    func turnFaceRec() {
        guard let token = token else { return }
        faceRecItem.switch.isEnabled = false
        let isOn = faceRecItem.switch.isOn
        let request = RecognizerRequest(recognizer: isOn)
        configDataSource.setFaceRecognition(request: request, token: token) { response, error in
            self.faceRecItem.switch.isEnabled = true
            guard let response = response else { return }
            self.faceRecItem.switch.isOn = response.recognizer
        }
    }
    
    @objc
    func turnMotion() {
        guard let token = token else { return }
        motionItem.switch.isEnabled = false
        let isOn = motionItem.switch.isOn
        let request = DetectorRequest(detector: isOn)
        configDataSource.setMotionDetector(request: request, token: token) { response, error in
            self.motionItem.switch.isEnabled = true
            guard let response = response else { return }
            self.motionItem.switch.isOn = response.detector
        }
    }
    
    @objc
    func resetMotion() {
        guard let token = token else { return }
        resetButton.isEnabled = false
        configDataSource.resetMotionDetector(token: token) { response, error in
            self.resetButton.isEnabled = true
            guard error == nil else {
                Banner.showError("Could not reset motion detector!")
                return
            }
            Banner.showSuccess("Motion detector was reset sucessfully!")
        }
    }
    
    @IBAction func backButtonTouched(_ sender: UIButton) {
        coordinator?.navigateBack()
    }
    
    // MARK: - Layout
    func createLayout() {
        // Main Stack View
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 40
        view.addSubview(stackView)
        stackView.layout {
            $0.top == backButton.bottomAnchor + 16
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor - 44
        }
        
        // Video Image View
        videoImageView.layout { $0.width == view.frame.width }
        stackView.addArrangedSubview(videoImageView)
        
        // Settings Stack View
        settingsStackView.axis = .vertical
        settingsStackView.distribution = .fillEqually
        settingsStackView.spacing = 30
        let face = layoutSettingItem(item: faceRecItem)
        let motion = layoutSettingItem(item: motionItem)
        settingsStackView.addArrangedSubview(face)
        settingsStackView.addArrangedSubview(motion)
        
        let buttonContainer = UIView()
        buttonContainer.addSubview(resetButton)
        resetButton.layout {
            $0.width == 229
            $0.height == 50
            $0.centerX == buttonContainer.centerXAnchor
            $0.centerY == buttonContainer.centerYAnchor
        }
        settingsStackView.addArrangedSubview(buttonContainer)
        settingsStackView.layout {
            $0.width == view.frame.width - 40
        }
        stackView.addArrangedSubview(settingsStackView)
    }
    
    func createSettingItem(iconName: String, title: String, subtitle: String) -> SettingItem {
        let image = UIImage(named: iconName)
        let imageView = UIImageView(image: image)
        imageView.layerCornerRadius = 6
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .textColor
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .thirdText
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.numberOfLines = 2
        
        let switchControl = UISwitch()
        switchControl.isEnabled = false
        
        return (imageView, titleLabel, subtitleLabel, switchControl)
    }
    
    func layoutSettingItem(item: SettingItem) -> UIStackView {
        item.icon.layout { $0.size == CGSize(width: 29, height: 29) }
        let horizontalStack = UIStackView(arrangedSubviews: [item.icon, item.title, item.switch])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, item.subtitle])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        return verticalStack
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.verticalSizeClass {
        case .compact:
            backButton.isHidden = true
            videoImageView.removeFromSuperview()
            view.fillWith(videoImageView)
            stackView.isHidden = true
            videoImageView.contentMode = .center
        default:
            stackView.isHidden = false
            backButton.isHidden = false
            videoImageView.removeFromSuperview()
            videoImageView.layout { $0.width == view.frame.width }
            stackView.insertArrangedSubview(videoImageView, at: 0)
            videoImageView.contentMode = .scaleAspectFill
        }
    }
}
