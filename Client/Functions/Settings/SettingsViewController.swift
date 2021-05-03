//
//  SettingsViewController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 17..
//

import KeychainAccess
import ClosureLayout
import UIKit
import OneSignal

class SettingsViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let sectionHeaderHeight: CGFloat = 56
        static let resetButtonTitle = "Reset Motion Detector"
        static let logoutButtonTitle = "Log out"
    }
    
    // MARK: - Data Source
    let configDataSource: ConfigDataSource = ConfigRemoteDataSource()
    
    // MARK: - Injected Properties
    weak var coordinator: SettingsCoordinator?
    private let keychain = Keychain()
    private lazy var token: String? = {
        return keychain["token"]
    }()
    
    // MARK: - UI Properties
    @IBOutlet weak var tableView: UITableView!

    lazy var titleLabel = UILabel()
    
    lazy var headerView: UIView = {
        let view = UIView()
        titleLabel.text = "Settings"
        titleLabel.textColor = .textColor
        titleLabel.font = .systemFont(ofSize: 43, weight: .bold)
        let size =  titleLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        titleLabel.frame.size = size
        titleLabel.frame.origin.x = 0
        view.frame.size = size
        view.frame.size.height += 4
        view.addSubview(titleLabel)
        return view
    }()
    
    // MARK: - View Models
    let sections = [
        (title: "Camera", iconName: "camera_icon", tint: UIColor.jarvisBlue),
        (title: "Events", iconName: "house_icon", tint: UIColor.jarvisGreen),
        (title: "App", iconName: "small_logo", tint: nil),
    ]
    
    lazy var viewModels = [[SettingsViewModel]]()
    
    lazy var recognitionVM = SettingsItemViewModel(
        config: .recognition,
        style: .first,
        selector: #selector(self.recognitionChanged(_:)),
        isEnabled: false,
        isOn: false
    )
    
    lazy var detectionVM = SettingsItemViewModel(
        config: .detection,
        style: .last,
        selector: #selector(self.motionChanged(_:)),
        isEnabled: false,
        isOn: false
    )
    
    lazy var notifiactionVM = SettingsItemViewModel(
        config: .notification,
        style: .only,
        selector: #selector(self.notificationChanged(_:)),
        isEnabled: true,
        isOn: true
    )
    
    lazy var darkmodeVM = SettingsItemViewModel(
        config: .darkmode,
        style: .only,
        selector: #selector(self.darkmodeChanged(_:)),
        isEnabled: true,
        isOn: !Theme.isDefault
    )
    
    lazy var resetVM = ButtonViewModel(
        title: Constants.resetButtonTitle,
        style: .normal,
        selector: #selector(resetPressed(_:))
    )
    
    lazy var logoutVM = ButtonViewModel(
        title: Constants.logoutButtonTitle,
        style: .destructive,
        selector: #selector(logoutPressed(_:))
    )
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .background
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top += 30
        tableView.contentInset.bottom = 50
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.register(SettingsCell.self)
        tableView.register(ButtonCell.self)
        Theme.register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConfig()
    }
    
    func createSectionHeader(title: String, iconName: String, tintColor: UIColor?) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .textColor
        let icon = UIImageView()
        icon.image = UIImage(named: iconName)
        icon.layout { $0.size == CGSize(width: 29, height: 29) }
        icon.tintColor = tintColor
        let stackView = UIStackView(arrangedSubviews: [icon, titleLabel])
        stackView.spacing = 8
        container.addSubview(stackView)
        stackView.layout {
            $0.leading == container.leadingAnchor
            $0.centerY == container.centerYAnchor - 4
        }
        return container
    }
    
    // MARK: - Actions
    @objc func recognitionChanged(_ sender: UISwitch) {
        guard let token = token else { return }
        sender.isEnabled = false
        let request = RecognizerRequest(recognizer: sender.isOn)
        configDataSource.setFaceRecognition(request: request, token: token) { response, error in
            sender.isEnabled = true
            guard error == nil else {
                sender.isOn.toggle()
                self.recognitionVM.isOn = sender.isOn
                return
            }
        }
    }
    
    @objc func motionChanged(_ sender: UISwitch) {
        guard let token = token else { return }
        sender.isEnabled = false
        let request = DetectorRequest(detector: sender.isOn)
        configDataSource.setMotionDetector(request: request, token: token) { response, error in
            sender.isEnabled = true
            guard error == nil else {
                sender.isOn.toggle()
                self.detectionVM.isOn = sender.isOn
                return
            }
        }
    }
    
    @objc func resetPressed(_ sender: UIButton) {
        guard let token = token else { return }
        sender.isEnabled = false
        configDataSource.resetMotionDetector(token: token) { response, error in
            sender.isEnabled = true
            guard error == nil else {
                Banner.showError("Could not reset motion detector!")
                return
            }
            Banner.showSuccess("Motion detector was reset sucessfully!")
        }
    }
    
    @objc func notificationChanged(_ sender: UISwitch) {
        notifiactionVM.isOn = sender.isOn
        OneSignal.disablePush(!sender.isOn)
    }
    
    @objc func darkmodeChanged(_ sender: UISwitch) {
        darkmodeVM.isOn = sender.isOn
        Theme.change()
    }
    
    @objc func logoutPressed(_ sender: UIButton) {
        keychain["token"] = nil
        OneSignal.removeExternalUserId()
        coordinator?.navigateToLogin()
    }
    
    func loadConfig() {
        guard let token = token else {
            coordinator?.navigateToLogin()
            return
        }
        
        configDataSource.getFaceRecognition(token: token) { res, err in
            guard let res = res else { return }
            self.recognitionVM.isEnabled = true
            self.recognitionVM.isOn = res.recognizer
            self.tableView.reloadData()
        }
        
        configDataSource.getMotionDetector(token: token) { res, err in
            guard let res = res else { return }
            self.detectionVM.isEnabled = true
            self.detectionVM.isOn = res.detector
            self.tableView.reloadData()
        }
        
        let state = OneSignal.getDeviceState()
        let isNotiDisabled = state?.isPushDisabled ?? true
        notifiactionVM.isOn = !isNotiDisabled
        
        viewModels = [
            [recognitionVM, detectionVM, resetVM],
            [notifiactionVM],
            [darkmodeVM, logoutVM]
        ]
        
        tableView.reloadData()
    }
}

// MARK: - Theme
extension SettingsViewController: ThemeResponding {
    func themeChanged() {
        view.backgroundColor = .background
        titleLabel.textColor = .textColor
        tableView.reloadData()
    }
}

// MARK: - Table View Delegates
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionHeader(
            title: sections[section].title,
            iconName: sections[section].iconName,
            tintColor: sections[section].tint
        )
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModels[indexPath.section][indexPath.row]
        switch vm {
        case let vm as SettingsItemViewModel:
            let cell = tableView.dequeuCellOfType(SettingsCell.self)
            cell.config = vm.config
            cell.style = vm.style
            cell.switchButton.isEnabled = vm.isEnabled
            cell.switchButton.isOn = vm.isOn
            cell.addTarget(self, action: vm.selector, for: .valueChanged)
            return cell
        case let vm as ButtonViewModel:
            let cell = tableView.dequeuCellOfType(ButtonCell.self)
            cell.title = vm.title
            cell.style = vm.style
            cell.addTarget(self, action: vm.selector, for: .touchUpInside)
            return cell
        default:
            fatalError()
        }
    }
    
}
