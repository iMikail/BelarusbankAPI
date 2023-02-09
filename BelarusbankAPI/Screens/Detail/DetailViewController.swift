//
//  DetailViewController.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 20.01.23.
//

import UIKit
import CoreLocation

protocol DetailDisplayLogic: AnyObject {
    func displayData(viewModel: Detail.Model.ViewModel.ViewModelData)
}

class DetailViewController: UIViewController, DetailDisplayLogic {
    var interactor: DetailBusinessLogic?
    var router: (NSObjectProtocol & DetailRoutingLogic & DetailDataPassing)?

    // MARK: - Properties
    private let reuseIdentifier = "reuseIdentifier"
    private var userCoordinate: CLLocationCoordinate2D?
    private var element: ElementDescription?
    private var descriptions = [String]()

    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none

        return tableView
    }()

    private lazy var routeButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Построить маршрут"
        configuration.image = UIImage(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
        configuration.imagePadding = 5.0
        configuration.imagePlacement = .bottom
        configuration.titleAlignment = .center

        button.configuration = configuration
        button.isEnabled = false
        button.addTarget(self, action: #selector(buildingRoute), for: .touchUpInside)

        return button
    }()

    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupVIPCycle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSubviews()
        setupConstraints()
        interactor?.makeRequest(request: .updateView)
    }

    func displayData(viewModel: Detail.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .updateView(let detailData):
            userCoordinate = detailData.userCoordinate
            element = detailData.element
            if let element = element {
                descriptions = element.arrayDescriptions()
                if userCoordinate != nil {
                    routeButton.isEnabled = true
                }
            }
        }
    }

    // MARK: Action funcs
    @objc private func buildingRoute() {
        guard let userCoordinate = userCoordinate, let element = element else { return }

        router?.openMap(element: element, userCoordinate: userCoordinate)
    }

    // MARK: Setup funcs
    private func setupVIPCycle() {
        let viewController = self
        let interactor = DetailInteractor()
        let presenter = DetailPresenter()
        let router = DetailRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(routeButton)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.trailing.top.leading.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(routeButton.snp.top).offset(-10.0)
        }

        routeButton.snp.makeConstraints { make in
            make.width.equalTo(200.0)
            make.height.equalTo(65.0)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - Extensions
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return descriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = descriptions[indexPath.row]
        content.textProperties.numberOfLines = 0
        content.textProperties.color = .label
        cell.contentConfiguration = content
        cell.isUserInteractionEnabled = false

        return cell
    }
}
