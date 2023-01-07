//
//  ATMViewCell.swift
//  task4
//
//  Created by Misha Volkov on 5.01.23.
//

import UIKit

final class ATMViewCell: UICollectionViewCell {
    static let identifier = "atmViewCell"

    internal var atm: ATM? {
        didSet {
            setupInfo()
        }
    }

    private lazy var installPlace: UILabel = createLabel()
    private lazy var workTime: UILabel = createLabel()
    private lazy var currency: UILabel = createLabel()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [installPlace, workTime, currency])
        let spacing: CGFloat = 5.0
        stackView.spacing = spacing
        stackView.layoutMargins = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .firstBaseline
        stackView.backgroundColor = .tertiaryLabel

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInfo() {
        guard let atm = atm else { return }

        installPlace.text = "\(atm.installPlace)"
        workTime.text = "Режим работы: \(atm.workTime)"
        currency.text = "Валюта: \(atm.currency)"
    }

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.numberOfLines = 0

        return label
    }
}
