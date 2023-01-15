//
//  ATMViewCell.swift
//  task4
//
//  Created by Misha Volkov on 5.01.23.
//

import UIKit

final class ElementViewCell: UICollectionViewCell {
    static let identifier = "elementViewCell"

    internal var bankElement: ElementResponse? {
        didSet {
            setupInfo()
        }
    }

    private lazy var titleLabel: UILabel = createLabelWithSize(13)
    private lazy var topLabel: UILabel = createLabelWithSize(11)
    private lazy var mediumLabel: UILabel = createLabelWithSize(11)
    private lazy var bottomLabel: UILabel = createLabelWithSize(11)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, topLabel, mediumLabel, bottomLabel])
        let spacing: CGFloat = 5.0
        stackView.layoutMargins = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiaryLabel
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInfo() {
        guard let bankElement = bankElement else { return }

        titleLabel.text = bankElement.elementType.elementName
        titleLabel.textAlignment = .center
        topLabel.text = bankElement.itemInstallPlace

        let workTime = "Режим работы:"
        if bankElement.elementType == .filial {
            mediumLabel.text = "Номер телефона: \(bankElement.itemPhoneInfo)"
            let text = workTime + "\n" + bankElement.itemWorkTime.split(separator: "|").joined(separator: "\n")
            bottomLabel.text = text
        } else {
            mediumLabel.text = "Валюта: \(bankElement.itemCurrency)"
            bottomLabel.text = workTime + " " + bankElement.itemWorkTime
        }
    }

    private func createLabelWithSize(_ size: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: size)
        label.numberOfLines = 0

        return label
    }
}
