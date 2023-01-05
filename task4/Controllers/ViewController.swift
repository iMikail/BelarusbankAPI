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

    private enum DisplayType: CaseIterable {
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

    // MARK: - Variables
    private let locationManager = CLLocationManager()
    private var atms = ATMResponse() {
        didSet {
            setupATMsOnMap()
        }
    }
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
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.setDividerImage(UIImage(systemName: "rectangle.portrait.lefthalf.inset.filled"),
                                         forLeftSegmentState: .selected,
                                         rightSegmentState: .normal,
                                         barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(systemName: "rectangle.portrait.righthalf.inset.filled"),
                                         forLeftSegmentState: .normal,
                                         rightSegmentState: .selected,
                                         barMetrics: .default)
        segmentedControl.tintColor = UIColor(named: ColorSets.blackWhite.rawValue)
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
        layout.itemSize = CGSize(width: 60, height: 60)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = isMapDisplayType

        collectionView.backgroundColor = .gray //delete
        return collectionView
    }()

    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Банкоматы"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
        atmCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell") //create custom cell

        attemptLocationAccess()
        fetchRequest()

        setupViews()
        setupConstraints()
    }

    private func attemptLocationAccess() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self

        switch locationManager.authorizationStatus {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .denied: break //add go options
        default: locationManager.requestLocation()
        }
    }

    @objc private func fetchRequest() {
        //add check Internet connection
        NetworkService.getData { [weak self] data in
            do {
                let atms = try ATMResponse(data: data)
                self?.atms = atms
                print("atms loaded, \(self?.atms.count)") //delete
            } catch {
                print(error)
            }
        }
    }

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

    @objc private func switchDisplayType() {
        isMapDisplayType = !isMapDisplayType
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
}

// MARK: - Extensions
extension ViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return atms.count
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .darkGray

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
}

extension ViewController: CLLocationManagerDelegate {
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            mapView.centerToLocation(location)
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

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
