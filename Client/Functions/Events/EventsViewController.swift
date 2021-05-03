//
//  EventsViewController.swift
//  Jarvis
//
//  Created by Foltányi Kolos on 2021. 03. 18..
//

import UIKit
import KeychainAccess
import ClosureLayout

class EventsViewController: UIViewController {
    private enum Constants {
        static let sectionHeaderHeight: CGFloat = 56
    }
    
    // MARK: - Injected Properties
    weak var coordinator: EventsCoordinator?
    
    // MARK: - Data Source
    private let eventsDataSource: EventsDataSource = EventsRemoteDataSource()
    private let keychain = Keychain()
    private lazy var token: String? = {
        return keychain["token"]
    }()
    
    // MARK: - UI Properties
    @IBOutlet weak var tableView: UITableView!
    
    lazy var titleLabel = UILabel()
    
    lazy var headerView: UIView = {
        let view = UIView()
        titleLabel.text = "Events"
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
    lazy var viewModels = [(title: String, events: [EventViewModel])]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .background
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top += 30
        tableView.contentInset.bottom = 70
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.register(EventCell.self)
        Theme.register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEvents()
    }
    
    func loadEvents() {
        let request = EventsRequest()
        guard let token = token else { return }
        eventsDataSource.getEvents(request: request, token: token) { response, error in
            guard let response = response else {
                self.handleError(error: error)
                return
            }
            self.createViewModels(from: response.events)
        }
    }
    
    func createViewModels(from events: [Event]) {
        
        var newest = events
        var pastWeek = [Event]()
        var earlier = [Event]()
        
        var other = [Event]()
        
        // Newest events (top 5)
        if events.count >= 5 {
            newest = Array(events[0..<5])
            other = Array(events[5..<events.count])
        }
        
        // Past week (if there is min 2)
        if events.count >= 7 {
            let date = Calendar.current.date(byAdding: .day, value: -7, to: Date())
            guard let aWeekAgo = date else {
                return
            }
            let filtered = other.filter {$0.time > Int(aWeekAgo.timeIntervalSince1970)}
            guard filtered.count > 2 else {
                return
            }
            pastWeek = filtered
            other = Array(other[filtered.count..<other.count])
        }
        
        // Every event earlier then one week
        if other.count > 0 {
            earlier = other
        }

        viewModels.removeAll()
        
        if newest.count > 0 {
            let vms = newest.map { EventViewModel(from: $0) }
            viewModels.append((title: "Newest", events: vms))
        }
        if pastWeek.count > 0 {
            let vms = pastWeek.map { EventViewModel(from: $0) }
            viewModels.append((title: "Past Week", events: vms))
        }
        if earlier.count > 0 {
            let vms = earlier.map { EventViewModel(from: $0) }
            viewModels.append((title: "Earlier", events: vms))
        }
        
        self.tableView.reloadData()
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
    
    func createSectionHeader(title: String) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .textColor
        container.addSubview(titleLabel)
        titleLabel.layout {
            $0.leading == container.leadingAnchor
            $0.centerY == container.centerYAnchor
        }
        return container
    }
}
// MARK: - Theme
extension EventsViewController: ThemeResponding {
    func themeChanged() {
        view.backgroundColor = .background
        titleLabel.textColor = .textColor
        tableView.reloadData()
    }
}

// MARK: - Table View Delegates
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionHeader(title: viewModels[section].title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderHeight
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[section].events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModels[indexPath.section].events[indexPath.row]
        let cell = tableView.dequeuCellOfType(EventCell.self)
        cell.titleLabel.text = vm.title
        cell.subtitleLabel.text = vm.subtitle
        cell.dateLabel.text = vm.dateString
        cell.iconImageView.image = vm.icon
        cell.style = indexPath.row == 0 ? .first : .middle
        if viewModels[indexPath.section].events.count == indexPath.row + 1 {
            cell.style = .last
        }
        return cell
    }
}
