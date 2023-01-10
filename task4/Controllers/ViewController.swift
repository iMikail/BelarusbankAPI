//
//  ViewController.swift
//  task4
//
//  Created by Misha Volkov on 28.12.22.
//

import UIKit
import SnapKit
import MapKit

final class ViewController: UIViewController {
    // MARK: - Properties
    internal let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    internal let itemsPerRow: CGFloat = 3
    private let locationManager = CLLocationManager()
    private let bankManager = BankManager()
    private var isMapDisplayType = true {
        didSet {
            mapView.isHidden = !isMapDisplayType
            atmCollectionView.isHidden = isMapDisplayType
            if !isMapDisplayType {
                atmCollectionView.reloadData()
            }
        }
    }

    // MARK: - Views
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Обновить"
        configuration.attributedTitle?.font = UIFont.systemFont(ofSize: 15.0)
        configuration.image = UIImage(systemName: "arrow.triangle.2.circlepath")
        configuration.imagePadding = 5.0

        button.configuration = configuration
        button.addTarget(self, action: #selector(fetchRequest), for: .touchUpInside)

        return button
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let items = DisplayType.allCases
        let segmentedControl = UISegmentedControl(items: items.map { $0.title })
        segmentedControl.selectedSegmentIndex = DisplayType.map.rawValue
        segmentedControl.setDividerImage(UIImage(systemName: "chevron.left.2"), forLeftSegmentState: .selected,
                                         rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(systemName: "chevron.right.2"), forLeftSegmentState: .normal,
                                         rightSegmentState: .selected, barMetrics: .default)
        segmentedControl.tintColor = .label
        segmentedControl.addTarget(self, action: #selector(switchDisplayType), for: .valueChanged)

        return segmentedControl
    }()

    private lazy var mapView: MKMapView = {
        let map = MKMapView(frame: .zero)
        map.delegate = self
        map.register(ATMAnnotationView.self, forAnnotationViewWithReuseIdentifier: ATMAnnotationView.identifier)
        map.isHidden = !isMapDisplayType
        map.showsUserLocation = true
        map.setRegion(map.belarusRegion, animated: true)

        return map
    }()

    private lazy var atmCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = bankManager
        collectionView.delegate = self
        collectionView.isHidden = isMapDisplayType

        return collectionView
    }()

    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта Банкоматов"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        atmCollectionView.register(ElementViewCell.self, forCellWithReuseIdentifier: ElementViewCell.identifier)
        atmCollectionView.register(SectionHeaderView.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                   withReuseIdentifier: SectionHeaderView.identifier)
        bankManager.delegate = self
        attemptLocationAccess()
        fetchRequest()
        setupViews()
        setupConstraints()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = atmCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }

    // MARK: Private funcs
    private func attemptLocationAccess() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self

        switch locationManager.authorizationStatus {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .denied: showDeniedAccessAlert()
        default: locationManager.requestLocation()
        }
    }

    // MARK: Action funcs
    @objc private func fetchRequest() {
        guard NetworkMonitor.shared.isConnected else {
            showNoInternetAlert()
            return
        }

        refreshButton.requestingState(true)
        NetworkService.getData(forBankElement: .atm) { [weak self] (data, error) in
            guard let self = self else { return }

            if let error = error {
                self.showErrorConnectionAlert(error: error)
            }

            if let data = data {
                self.bankManager.updateElements([.atm], fromData: data)
            }
            self.refreshButton.requestingState(false)
        }
    }

    @objc private func switchDisplayType() {
        isMapDisplayType = !isMapDisplayType
        let index = isMapDisplayType ? DisplayType.map.rawValue : DisplayType.list.rawValue
        segmentedControl.selectedSegmentIndex = index

        if let title = DisplayType(rawValue: index)?.title {
            self.title = "\(title) банкоматов"
        }
    }

    // MARK: Setup funcs
    private func setupATMsOnMap() {
        let oldAnnotations = mapView.annotations
        var newAnnotations = [ATMAnnotation]()
            bankManager.atms.forEach { atm in
            let annotation = ATMAnnotation(fromATM: atm)
            newAnnotations.append(annotation)
        }

        mapView.removeAnnotations(oldAnnotations)
        mapView.addAnnotations(newAnnotations)
    }

    private func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(mapView)
        view.addSubview(atmCollectionView)
    }

    private func setupConstraints() {
        segmentedControl.snp.makeConstraints { make in
            make.width.equalTo(150.0)
            make.height.equalTo(30.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        mapView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(segmentedControl.snp.bottom).offset(5.0)
        }
        atmCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(mapView)
        }
    }

    // MARK: AlertController funcs
    private func showNoInternetAlert() {
        let alertController = UIAlertController(title: "Отсутствует интернет соединение",
                                                message: "Приложение не работает без доступа к интернету",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .cancel)
        alertController.addAction(action)

        present(alertController, animated: true)
    }

    private func showErrorConnectionAlert(error: Error) {
        let alertController = UIAlertController(title: "Ошибка сети",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        let repeatAction = UIAlertAction(title: "Повторить ещё раз", style: .default) { [weak self] _ in
            self?.fetchRequest()
        }
        let canselAction = UIAlertAction(title: "Закрыть", style: .cancel)

        alertController.addAction(repeatAction)
        alertController.addAction(canselAction)

        present(alertController, animated: true)
    }

    private func showDeniedAccessAlert() {
        let message = "Без доступа невозможно строить маршруты, перейдите в настройки служб геолокации"
        let alertController = UIAlertController(title: "Доступ к геолокации запрещён",
                                                message: message,
                                                preferredStyle: .alert)
        let optionAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingUrl) {
                UIApplication.shared.open(settingUrl)
            }
        }
        let canselAction = UIAlertAction(title: "Отмена", style: .cancel)

        alertController.addAction(optionAction)
        alertController.addAction(canselAction)

        present(alertController, animated: true)
    }
}

// MARK: - Extensions: CollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentId = bankManager.sortedAtms[indexPath.section][indexPath.row].id

        if let annotation = mapView.annotations.first(where: { annotation in
            if let atmAnnotation = annotation as? ATMAnnotation {
                return atmAnnotation.id == currentId
            } else {
                return false
            }
        }) {
            switchDisplayType()
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

}

// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
            if let location = manager.location {
                mapView.centerToLocation(location)
            }
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            mapView.centerToLocation(location)
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? ATMAnnotation else { return nil }

        var view: ATMAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: ATMAnnotationView.identifier) as? ATMAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = ATMAnnotationView(annotation: annotation, reuseIdentifier: ATMAnnotationView.identifier)
        }
        view.delegate = self
        view.atmAnnotation = annotation

        return view
    }
}

// MARK: ATMViewCellDelegate
extension ViewController: ATMViewCellDelegate {
    func fetchMoreInfo(forAtmId id: String) {
        let detailVC = DetailViewController()
        detailVC.atm = bankManager.atms.first(where: { $0.id == id })
        detailVC.userCoordinate = locationManager.location?.coordinate

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: BankManagerDelegate
extension ViewController: BankManagerDelegate {
    func infoboxDidUpdate() {

    }

    func filialsDidUpdate() {

    }

    func atmsDidUpdate() {
        setupATMsOnMap()
    }
}
