//
//  HomeViewController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 15..
//

import ClosureLayout
import KeychainAccess
import UIKit

class HomeViewController: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let snapshot = "snapshot"
        static let authorization = "Authorization"
        static let sectionHeaderHeight: CGFloat = 56
    }
    
    // MARK: - Data Source
    private var eventsDataSource: EventsDataSource = EventsRemoteDataSource()
    private let keychain = Keychain()
    private lazy var token: String? = {
        return keychain["token"]
    }()
    
    // MARK: - Injected Properties
    weak var coordinator: HomeCoordinator?
    
    // MARK: - UI Properties
    @IBOutlet weak var tableView: UITableView!
        
    lazy var titleLabel = UILabel()
    
    lazy var headerView: UIView = {
        let view = UIView()
        titleLabel.text = "Home"
        titleLabel.textColor = .textColor
        titleLabel.font = .systemFont(ofSize: 43, weight: .bold)
        let size =  titleLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        titleLabel.frame.size = size
        titleLabel.frame.origin.x = 0
        view.frame.size = size
        view.addSubview(titleLabel)
        return view
    }()
    
    // MARK: - View Models
    lazy var sections = [(
        title: "Camera",
        iconName: "camera_icon",
        tint: UIColor.jarvisBlue,
        buttonTitle: nil,
        selector: nil
    ), (
        title: "Events",
        iconName: "house_icon",
        tint: UIColor.jarvisGreen,
        buttonTitle: "See All",
        selector: #selector(seeAllTapped)
    )]
    
    let cam = CameraViewModel(
        title: "Cam1",
        subtitle: "last event: 2021.03.12."
    )
    
    lazy var cameras = [cam]
    lazy var events = [EventViewModel]()
    
    var viewModels: [[HomeListViewModel]] {
        return [cameras, events]
    }
    
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
        tableView.register(CameraCell.self)
        tableView.register(EventCell.self)
        Theme.register(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadEvents()
    }
    
    // MARK: - Actions
    @objc func seeAllTapped() {
        coordinator?.navigateToEvents()
    }
    
    // MARK: - Helpers
    typealias SectionConfig = (
        title: String,
        iconName: String,
        tintColor: UIColor,
        buttonTitle: String?,
        selector: Selector?
    )
    
    func createSectionHeader(config: SectionConfig) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = config.title
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .textColor
        let icon = UIImageView()
        icon.image = UIImage(named: config.iconName)
        icon.layout { $0.size == CGSize(width: 29, height: 29) }
        icon.tintColor = config.tintColor
        let stackView = UIStackView(arrangedSubviews: [icon, titleLabel])
        stackView.spacing = 8
        container.addSubview(stackView)
        stackView.layout {
            $0.leading == container.leadingAnchor
            $0.centerY == container.centerYAnchor
        }
        if let buttonTitle = config.buttonTitle, let selector = config.selector{
            let button = UIButton()
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(UIColor(0x2F80ED), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            container.addSubview(button)
            button.layout {
                $0.centerY == container.centerYAnchor
                $0.trailing == container.trailingAnchor - 2
            }
        }
        
        return container
    }
    
    // MARK: - Data
    func loadEvents() {
        let request = EventsRequest(limit: 10)
        guard let token = token else {
            coordinator?.navigateToLogin()
            return
        }
        eventsDataSource.getEvents(request: request, token: token) { response, error in
            guard let response = response else {
                self.handleError(error: error)
                return
            }
            self.events = response.events.map { EventViewModel(from: $0) }
            // TODO: Set Last Event for camera from: self.events.first?.dateString
            self.tableView.reloadData()
        }
    }
    
    func handleError(error: DataSourceError?) {
        guard let error = error else {
            Banner.showError()
            return
        }
        Banner.showError(error.message)
        if error.statusCode == 403 {
            self.keychain["token"] = nil
            self.coordinator?.navigateToLogin()
        }
        return
    }
    
    func loadSnapshot(into imageView: UIImageView) {
        guard let token = token else { return }
        guard imageView.image == nil else { return }
        let url = Environment.host.appendingPathComponent(Constants.snapshot)
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: Constants.authorization)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
    }
}
// MARK: - Theme
extension HomeViewController: ThemeResponding {
    func themeChanged() {
        view.backgroundColor = .background
        titleLabel.textColor = .textColor
        tableView.reloadData()
    }
}

// MARK: - Table View Delegates
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let config = (
            title: sections[section].title,
            iconName: sections[section].iconName,
            tintColor: sections[section].tint,
            buttonTitle: sections[section].buttonTitle,
            selector: sections[section].selector
        )
        return createSectionHeader(config: config)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderHeight
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModels[indexPath.section][indexPath.row] {
        case let vm as CameraViewModel:
            let cell = tableView.dequeuCellOfType(CameraCell.self)
            cell.titleLabel.text = vm.title
            cell.subtitleLabel.text = vm.subtitle
            loadSnapshot(into: cell.cameraImageView)
            return cell
        case let vm as EventViewModel:
            let cell = tableView.dequeuCellOfType(EventCell.self)
            cell.titleLabel.text = vm.title
            cell.subtitleLabel.text = vm.subtitle
            cell.dateLabel.text = vm.dateString
            cell.iconImageView.image = vm.icon
            cell.style = indexPath.row == 0 ? .first : .middle
            if viewModels[indexPath.section].count == indexPath.row + 1 {
                cell.style = .last
            }
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModels[indexPath.section][indexPath.row] is CameraViewModel {
            coordinator?.navigateToCameraDetail()
        }
    }
}

