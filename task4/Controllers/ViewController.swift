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
            collectionView.isHidden = isMapDisplayType
            if bankManager.filteredBankElements.isEmpty {
                loaderView.setHidden(false)
            }
        }
    }
    private var isFirstRequest = true

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
        map.register(ElementAnnotationView.self, forAnnotationViewWithReuseIdentifier: ElementAnnotationView.identifier)
        map.isHidden = !isMapDisplayType
        map.showsUserLocation = true
        map.setRegion(map.belarusRegion, animated: true)

        return map
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = isMapDisplayType

        return collectionView
    }()

    private lazy var loaderView = LoaderView(style: .medium)
    private lazy var checkboxView = CheckboxView()

    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mappin.circle"),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(toggleCheckboxView))

        collectionView.register(ElementViewCell.self, forCellWithReuseIdentifier: ElementViewCell.identifier)
        collectionView.register(SectionHeaderView.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                   withReuseIdentifier: SectionHeaderView.identifier)
        bankManager.delegate = self
        checkboxView.delegate = self
        attemptLocationAccess()
        fetchRequest()
        setupViews()
        setupConstraints()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
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

    private func setEnabledInterface(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        navigationController?.navigationBar.isUserInteractionEnabled = enabled
        refreshButton.requestingState(!enabled)
        loaderView.setHidden(enabled)
    }

    // MARK: Action funcs
    @objc private func toggleCheckboxView() {
        checkboxView.isHidden = !checkboxView.isHidden
    }

    @objc private func switchDisplayType() {
        isMapDisplayType = !isMapDisplayType
        let index = isMapDisplayType ? DisplayType.map.rawValue : DisplayType.list.rawValue
        segmentedControl.selectedSegmentIndex = index
        self.title = DisplayType(rawValue: index)?.title
    }

    @objc private func fetchRequest() {
        setEnabledInterface(false)
        let location = locationManager.location ?? locationManager.defaultLocation
        if isFirstRequest {
            bankManager.updateDataForTypes(BankElements.allCases,
                                           location: location) { [weak self] (connected, errorElements) in
                guard let self = self else { return }
                self.setEnabledInterface(true)
                self.isFirstRequest = false

                if connected {
                    if let errorElements = errorElements {
                        self.showErrorConnectionAlert(errorElements: errorElements)
                    }
                } else {
                    self.showNoInternetAlert()
                }
            }
        } else {
            bankManager.updateDataForTypes([.atm], location: location) { [weak self] (connected, _) in
                self?.setEnabledInterface(true)
                if !connected {
                    self?.showNoInternetAlert()
                }
            }
            bankManager.updateDataForTypes([.infobox], location: location)
            bankManager.updateDataForTypes([.filial], location: location)
        }
    }

    // MARK: Setup funcs
    private func setupElementsOnMapForTypes(_ types: [BankElements]) {
        let oldAnnotations = mapView.annotations.filter { annotation in
            if let elementAnnotation = annotation as? ElementAnnotation {
                return !types.contains(elementAnnotation.elementType)
            } else {
                return true
            }
        }
        mapView.removeAnnotations(oldAnnotations)

        var newAnnotations = [ElementAnnotation]()
        bankManager.allBankElements.forEach { element in
            if types.contains(element.elementType) {
                let annotation = ElementAnnotation(fromElement: element)
                newAnnotations.append(annotation)
            }
        }
        mapView.addAnnotations(newAnnotations)
    }

    private func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(mapView)
        view.addSubview(collectionView)
        view.addSubview(checkboxView)
        view.addSubview(loaderView)
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
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(mapView)
        }
        checkboxView.snp.makeConstraints { make in
            make.left.equalTo(mapView.snp.left)
            make.top.equalTo(mapView.snp.top)
        }
        loaderView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.centerY.equalToSuperview()
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

    private func showErrorConnectionAlert(errorElements: [ErrorForElement]) {
        var message = ""
        errorElements.forEach { (error, type) in
            message += "\(type.elementName): \(error.localizedDescription)\n"
        }
        let alertController = UIAlertController(title: "Не удалось обновить элементы",
                                                message: message,
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
        let currentId = bankManager.filteredBankElements[indexPath.section][indexPath.row].id
        let currentType = bankManager.filteredBankElements[indexPath.section][indexPath.row].elementType

        if let annotation = mapView.annotations.first(where: { annotation in
            if let elementAnnotation = annotation as? ElementAnnotation {
                return elementAnnotation.id == currentId && elementAnnotation.elementType == currentType
            } else {
                return false
            }
        }) {
            switchDisplayType()
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return bankManager.filteredBankElements.count
    }

    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bankManager.filteredBankElements[section].count
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ElementViewCell.identifier,
            for: indexPath) as? ElementViewCell else {
            return UICollectionViewCell()
        }

        cell.bankElement = bankManager.filteredBankElements[indexPath.section][indexPath.row]

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

        headerView.titleLabel.text = bankManager.filteredBankElements[indexPath.section].first?.city

        return headerView
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40.0)
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
        guard let annotation = annotation as? ElementAnnotation else { return nil }

        var view: ElementAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: ElementAnnotationView.identifier) as? ElementAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = ElementAnnotationView(annotation: annotation, reuseIdentifier: ElementAnnotationView.identifier)
        }
        view.delegate = self
        view.elementAnnotation = annotation

        return view
    }
}

// MARK: ElementAnnotationViewDelegate
extension ViewController: ElementAnnotationViewDelegate {
    func fetchMoreInfoForElement(_ type: BankElements, id: String) {
        let detailVC = DetailViewController()
        detailVC.userCoordinate = locationManager.location?.coordinate
        detailVC.element = bankManager.fetchElement(type, id: id)

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: BankManagerDelegate
extension ViewController: BankManagerDelegate {
    func bankElementsDidFiltered() {
        if loaderView.isAnimating {
            loaderView.setHidden(true)
        }
        collectionView.reloadData()
    }

    func bankElementsDidUpdated() {
        setupElementsOnMapForTypes(checkboxView.selectedTypes)
    }
}

// MARK: - CheckboxViewDelegate
extension ViewController: CheckboxViewDelegate {
    func selectedTypesDidChanched(_ types: [BankElements]) {
        bankManager.updateFilteredTypes(types)
        setupElementsOnMapForTypes(types)
    }
}
