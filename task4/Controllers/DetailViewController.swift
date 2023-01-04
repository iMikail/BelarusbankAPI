//
//  DetailViewController.swift
//  task4
//
//  Created by Misha Volkov on 4.01.23.
//

import UIKit

final class DetailViewController: UIViewController {

    private let reuseIdentifier = "reuseIdentifier"
    internal var atm: ATM? {
        didSet {
            if let atm = atm {
                descriptions = atm.arrayDescriptions()
            }
        }
    }

    private var descriptions = [String]()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self

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
        button.addTarget(self, action: #selector(buildingRoute), for: .touchUpInside)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupSubviews()
        setupConstraints()
    }

    @objc private func buildingRoute() {
        print("build route") //delete
    }

    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(routeButton)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.trailing.top.leading.equalToSuperview()
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

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return descriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = descriptions[indexPath.row]

        return cell
    }
}
