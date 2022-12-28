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
  private var points = [1, 2, 3]
  private var isMapDisplayType = true {
    didSet {
      mapView.isHidden = !isMapDisplayType
      atmCollectionView.isHidden = isMapDisplayType
    }
  }

  // MARK: - Views
  private lazy var refreshButton: UIButton = {
    let button = UIButton()
    var configuration = UIButton.Configuration.plain()
    configuration.title = "Обновить"
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
    map.isHidden = !isMapDisplayType

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
  private lazy var routeButton: UIButton = {
    let button = UIButton()
    var configuration = UIButton.Configuration.filled()
    configuration.title = "Построить маршрут"
    configuration.image = UIImage(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
    configuration.imagePadding = 5.0
    configuration.imagePlacement = .bottom
    configuration.titleAlignment = .center

    button.configuration = configuration
    button.addTarget(self, action: #selector(buildingRoute), for: .touchUpInside)

    return button
  }()

  // MARK: - Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Банкоматы Беларусбанка"
    view.backgroundColor = .systemBackground
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
    atmCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell") //create custom cell

    setupViews()
  }

  @objc private func fetchRequest() {
    print("fetch request") //delete
  }

  @objc private func buildingRoute() {
    print("build route") //delete
  }

  @objc private func switchDisplayType() {
    isMapDisplayType = !isMapDisplayType
    print("switch displayType") //delete
  }

  private func setupViews() {
    view.addSubview(segmentedControl)
    view.addSubview(mapView)
    view.addSubview(atmCollectionView)
    view.addSubview(routeButton)

    segmentedControl.snp.makeConstraints { make in
      make.width.equalTo(150.0)
      make.height.equalTo(30.0)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.centerX.equalToSuperview()
    }

    let spacing: CGFloat = 10.0
    mapView.snp.makeConstraints { make in
      make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.top.equalTo(segmentedControl.snp.bottom).offset(spacing)
      make.bottom.equalTo(routeButton.snp.top).offset(-spacing)
    }

    atmCollectionView.snp.makeConstraints { make in
      make.edges.equalTo(mapView)
    }

    routeButton.snp.makeConstraints { make in
      make.width.equalTo(200.0)
      make.height.equalTo(65.0)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      make.centerX.equalToSuperview()
    }
  }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return points.count
  }

  internal func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    cell.backgroundColor = .darkGray

    return cell
  }

}
