//
//  DetailViewController.swift
//  task4
//
//  Created by Misha Volkov on 20.01.23.
//

import MapKit

protocol DetailDisplayLogic: AnyObject {
    func displayData(viewModel: Detail.Model.ViewModel.ViewModelData)
}

class DetailViewController: UIViewController, DetailDisplayLogic {
    var interactor: DetailBusinessLogic?
    var router: (NSObjectProtocol & DetailRoutingLogic & DetailDataPassing)?

    // MARK: - Properties
    private let reuseIdentifier = "reuseIdentifier"
    var userCoordinate: CLLocationCoordinate2D? {
        didSet {
            if userCoordinate != nil {
                routeButton.isEnabled = true
            }
        }
    }

    var element: ElementDescription? {
        didSet {
            if let element = element {
                descriptions = element.arrayDescriptions()
            }
        }
    }
    private var descriptions = [String]()

    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.separatorColor = .secondaryLabel
        tableView.separatorInset = UIEdgeInsets.zero

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
        setup()
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
        }
    }

    private func setup() {
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

    @objc private func buildingRoute() {
        guard
            let userCoordinate = userCoordinate,
            let element = element,
            let latitude = Double(element.latitude),
            let longitude = Double(element.longitude) else { return }

        let userMapItem = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        userMapItem.name = "Моё местоположение"

        let atmCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let atmMapItem = MKMapItem(placemark: MKPlacemark(coordinate: atmCoordinate))
        atmMapItem.name = element.elementType.elementName

        MKMapItem.openMaps(with: [userMapItem, atmMapItem],
                           launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
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
        if let textLabel = cell.textLabel {
            textLabel.numberOfLines = 0
            textLabel.text = descriptions[indexPath.row]
            textLabel.textAlignment = .center
        }
        cell.isUserInteractionEnabled = false

        return cell
    }
}
