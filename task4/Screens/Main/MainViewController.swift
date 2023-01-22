//
//  MainViewController.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit
import SnapKit
import MapKit

protocol MainDisplayLogic: AnyObject {
    func displayData(viewModel: Main.Model.ViewModel.ViewModelData)
}

class MainViewController: UIViewController, MainDisplayLogic {
    enum DisplayType: Int, CaseIterable {
        case map
        case list

        var title: String {
            switch self {
            case .map: return "Карта"
            case .list: return "Список"
            }
        }
    }

    // MARK: - Properties
    var interactor: MainBusinessLogic?
    var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing & ElementAnnotationViewDelegate)?

    private var alertManager = AlertManager()
    private var filteredBankElements = [[ElementResponse]]()
    private var isMapDisplayType = true {
        didSet {
            mapView.isHidden = !isMapDisplayType
            listView.isHidden = isMapDisplayType
            if filteredBankElements.isEmpty {
                loaderView.setHidden(isMapDisplayType)
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
        let segmentedControl = UISegmentedControl(items: DisplayType.allCases.map { $0.title })
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
        map.showsUserLocation = true
        map.setRegion(map.belarusRegion, animated: true)

        return map
    }()

    private lazy var listView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var loaderView = LoaderView(style: .medium)
    private lazy var checkboxView = CheckboxView()

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVIPCycle()
        setupFirstOptions()
        setupDelegates()
        registerViews()
        interactor?.makeRequest(request: .attemptLocationAccess)
        fetchRequest()
        setupViews()
        setupConstraints()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = listView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        flowLayout.invalidateLayout()
    }

    func displayData(viewModel: Main.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .showAlert(let alertType):
            showAlert(alertType)
        case .enabledInterface:
            setEnabledInterface(true)
        case .updateAnnotations(let annotations, let types):
            setupAnnotations(annotations, forTypes: types)
        case .updateSortedBankElements(let elements):
            interactor?.sortedBankElements = elements
        case .updateFilteredElements(let elements):
            filteredBankElements = elements
            loaderView.setHidden(true)
            listView.reloadData()
        case .updateLocation(let location):
            mapView.centerToLocation(location)
        }
    }

    // MARK: Setup
    private func setupVIPCycle() {
        let viewController = self
        let interactor = MainInteractor()
        let worker = MainService()
        let presenter = MainPresenter()
        let router = MainRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.service = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
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
        mapView.delegate = self
        listView.delegate = self
        listView.dataSource = self
        checkboxView.delegate = self
        alertManager.delegate = self
    }

    private func setEnabledInterface(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        navigationController?.navigationBar.isUserInteractionEnabled = enabled
        refreshButton.requestingState(!enabled)
        loaderView.setHidden(enabled)
    }

    private func showAlert(_ alertType: Main.AlertType) {
        var alertController: UIAlertController
        switch alertType {
        case .noInternet:
            alertController = alertManager.createNoInternetAlert()
        case .noLocationAccess:
            alertController = alertManager.createDeniedAccessAlert()
        case .errorConnection(let errors):
            alertController = alertManager.createErrorConnectionAlert(errors)
        }

        present(alertController, animated: true)
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
        interactor?.makeRequest(request: .updateData)
    }

    // MARK: Setup funcs
    private func setupAnnotations(_ annotations: [ElementAnnotation], forTypes: [BankElements]) {
        let oldAnnotations = mapView.annotations.filter { annotation in
            if let elementAnnotation = annotation as? ElementAnnotation {
                return !forTypes.contains(elementAnnotation.elementType)
            } else {
                return true
            }
        }
        mapView.removeAnnotations(oldAnnotations)
        mapView.addAnnotations(annotations)
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
}

// MARK: - Extensions: CollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentId = filteredBankElements[indexPath.section][indexPath.row].itemId
        let currentType = filteredBankElements[indexPath.section][indexPath.row].elementType

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
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredBankElements.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBankElements[section].count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ElementViewCell.identifier,
                                                            for: indexPath) as? ElementViewCell else {
            return UICollectionViewCell()
        }

        cell.bankElement = filteredBankElements[indexPath.section][indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }

        headerView.titleLabel.text = filteredBankElements[indexPath.section].first?.itemCity

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40.0)
    }
}

// MARK: MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
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
        view.delegate = router
        view.elementAnnotation = annotation

        return view
    }
}

// MARK: AlertControllerDelegate
extension MainViewController: AlertControllerDelegate {
    func needRepeatRequest() {
        fetchRequest()
    }
}

// MARK: CheckboxViewDelegate
extension MainViewController: CheckboxViewDelegate {
    func selectedTypesDidChanched(_ types: [BankElements]) {
        interactor?.makeRequest(request: .updateFilteredTypes(types))
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    private var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    }
    private var itemsPerRow: CGFloat { return 3 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let itemWidth = availableWidth / itemsPerRow

        return CGSize(width: itemWidth, height: itemWidth)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
