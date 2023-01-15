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
    private let locationManager = CLLocationManager()
    private let bankManager = BankManager()
    private var isMapDisplayType = true {
        didSet {
            mapView.isHidden = !isMapDisplayType
            listView.isHidden = isMapDisplayType
            if bankManager.filteredBankElements.isEmpty {
                loaderView.setHidden(isMapDisplayType)
            }
        }
    }
    private var isFirstRequest = true

    // MARK: - Views
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.setupRefreshConfigurating()
        button.addTarget(self, action: #selector(fetchRequest), for: .touchUpInside)

        return button
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: DisplayType.allCases.map { $0.title })
        segmentedControl.setupConfigurating()
        segmentedControl.addTarget(self, action: #selector(switchDisplayType), for: .valueChanged)

        return segmentedControl
    }()

    private lazy var mapView: MKMapView = {
        let map = MKMapView(frame: .zero)
        map.showsUserLocation = true
        map.setRegion(map.belarusRegion, animated: true)

        return map
    }()

    private lazy var listView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var loaderView = LoaderView(style: .medium)
    private lazy var checkboxView = CheckboxView()

    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirstOptions()
        setupDelegates()
        registerViews()
        attemptLocationAccess()
        fetchRequest()
        setupViews()
        setupConstraints()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = listView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.invalidateLayout()
    }

    // MARK: Private funcs
    private func setupFirstOptions() {
        title = "Карта"
        view.backgroundColor = .systemBackground
        let leftItem = UIBarButtonItem(image: UIImage(systemName: "checklist.rtl"), style: .done,
                                       target: self, action: #selector(toggleCheckboxView))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        navigationItem.leftBarButtonItem = leftItem
        listView.isHidden = true
    }

    private func registerViews() {
        mapView.register(ElementAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: ElementAnnotationView.identifier)
        listView.register(ElementViewCell.self, forCellWithReuseIdentifier: ElementViewCell.identifier)
        listView.register(SectionHeaderView.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                   withReuseIdentifier: SectionHeaderView.identifier)
    }

    private func setupDelegates() {
        bankManager.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
        listView.delegate = self
        listView.dataSource = self
        checkboxView.delegate = self
    }

    private func attemptLocationAccess() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
            bankManager.updateData(location: location) { [weak self] (connected, errorElements) in
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
            bankManager.updateData(forTypes: [.atm], location: location) { [weak self] (connected, _) in
                self?.setEnabledInterface(true)
                if !connected {
                    self?.showNoInternetAlert()
                }
            }
            bankManager.updateData(forTypes: [.infobox], location: location)
            bankManager.updateData(forTypes: [.filial], location: location)
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
        view.addSubview(listView)
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
        listView.snp.makeConstraints { make in
            make.edges.equalTo(mapView)
        }
        checkboxView.snp.makeConstraints { make in
            make.left.top.equalTo(view.safeAreaLayoutGuide)

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
        let currentId = bankManager.filteredBankElements[indexPath.section][indexPath.row].itemId
        let currentType = bankManager.filteredBankElements[indexPath.section][indexPath.row].elementType

        if let annotation = mapView.annotations.first(where: { annotation in
            if let elementAnnotation = annotation as? ElementAnnotation {
                return elementAnnotation.itemId == currentId && elementAnnotation.elementType == currentType
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ElementViewCell.identifier,
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
            for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }

        headerView.titleLabel.text = bankManager.filteredBankElements[indexPath.section].first?.itemCity

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
        print(error)
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
        listView.reloadData()
    }

    func bankElementsDidUpdated() {
        setupElementsOnMapForTypes(checkboxView.selectedTypes)
    }
}

// MARK: CheckboxViewDelegate
extension ViewController: CheckboxViewDelegate {
    func selectedTypesDidChanched(_ types: [BankElements]) {
        bankManager.updateFilteredTypes(types)
        setupElementsOnMapForTypes(types)
    }
}
