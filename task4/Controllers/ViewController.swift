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

    private enum DisplayType: Int, CaseIterable {
        case map
        case list

        var title: String {
            switch self {
            case .map: return "Карта"
            case .list: return "Список"
            }
        }
        var image: UIImage? {
            switch self {
            case .map: return UIImage(systemName: "map")
            case .list: return UIImage(systemName: "list.bullet.rectangle")
            }
        }
    }

    // MARK: - Properties
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    private let locationManager = CLLocationManager()
    private var atms = ATMResponse() {
        didSet {
            setupATMsOnMap()
            sortedAtms = sortAtmsByCities()
        }
    }
    private var sortedAtms = [ATMResponse]()
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
        configuration.image = UIImage(systemName: "arrow.triangle.2.circlepath") //add animation
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
        collectionView.dataSource = self
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
        atmCollectionView.register(ATMViewCell.self, forCellWithReuseIdentifier: ATMViewCell.identifier)
        atmCollectionView.register(SectionHeaderView.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                   withReuseIdentifier: SectionHeaderView.identifier)
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
    private func sortAtmsByCities() -> [ATMResponse] {
        var atms = atms
        var sortedAtms = [ATMResponse]()

        while !atms.isEmpty {
            var array = ATMResponse()
            let city = atms[0].city

            for atm in atms where atm.city == city {
                array.append(atm)
            }
            atms.removeAll { $0.city == city }
            sortedAtms.append(array)
        }

        return sortedAtms.map { $0.sorted { $0.id < $1.id } }
    }

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

        refreshButton.isEnabled = false
        NetworkService.getData { [weak self] (data, error, enabled) in
            guard let self = self else { return }

            if let error = error {
                self.showErrorConnectionAlert(error: error)
            }

            if let data = data {
                do {
                    let atms = try ATMResponse(data: data)
                    self.atms = atms
                } catch {
                    print(error)
                }
            }
            self.refreshButton.isEnabled = enabled
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
        atms.forEach { atm in
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

        let spacing: CGFloat = 5.0
        mapView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(segmentedControl.snp.bottom).offset(spacing)
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

// MARK: - Extensions: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {

    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedAtms.count
    }

    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedAtms[section].count
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ATMViewCell.identifier,
            for: indexPath) as? ATMViewCell else {
            return UICollectionViewCell()
        }

        cell.atm = sortedAtms[indexPath.section][indexPath.row]

        return cell
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }

        headerView.titleLabel.text = sortedAtms[indexPath.section].first?.city

        return headerView
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40.0)
    }
}

// MARK: CollectionViewDelegate
extension ViewController: UICollectionViewDelegate {

    // Открытие аннотации на карте по нажатию на карточку
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentId = sortedAtms[indexPath.section][indexPath.row].id

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

// MARK: UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let itemWidth = availableWidth / itemsPerRow

        return CGSize(width: itemWidth, height: itemWidth)
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
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

        view.atmAnnotation = annotation
        view.idHandler = { [weak self] id in
            guard let self = self  else { return }

            let detailVC = DetailViewController()
            detailVC.atm = self.atms.first(where: { $0.id == id })
            detailVC.userCoordinate = self.locationManager.location?.coordinate

            self.navigationController?.pushViewController(detailVC, animated: true)
        }

        return view
    }
}
