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

    private lazy var installPlace: UILabel = createLabel()
    private lazy var workTime: UILabel = createLabel()
    private lazy var dopInfo: UILabel = createLabel()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [installPlace, workTime, dopInfo])
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
        guard let bankElement = bankElement else { return }

        installPlace.text = "\(bankElement.elementType.elementName)\n\(bankElement.installPlace)"
        let workTime = "Режим работы:"
        if bankElement.elementType == .filial {
            self.workTime.text = workTime + "\n" + bankElement.workTime.split(separator: "|").joined(separator: "\n")
            dopInfo.text = "Номер телефона: \(bankElement.phoneInfo)"
        } else {
            self.workTime.text = workTime + " " + bankElement.workTime
            dopInfo.text = "Валюта: \(bankElement.currency)"
        }
    }

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.numberOfLines = 0

        return label
    }
}
