//
//  CheckboxView.swift
//  task4
//
//  Created by Misha Volkov on 13.01.23.
//

import UIKit

protocol CheckboxViewDelegate: AnyObject {
    func selectedTypesDidChanched(_ types: [BankElements])
}

final class CheckboxView: UIView {
    // MARK: - Properties
    weak var delegate: CheckboxViewDelegate?

    // MARK: - Views
    private lazy var atmCheckButton = createCheckboxButtonForType(.atm)
    private lazy var infoboxCheckButton = createCheckboxButtonForType(.infobox)
    private lazy var filialCheckButton = createCheckboxButtonForType(.filial)

    var selectedTypes = BankElements.allCases {
        didSet {
            delegate?.selectedTypesDidChanched(selectedTypes)
        }
    }

    private lazy var stackView: UIStackView = {
        let atmView = createHorizontalStackViewFor([createLabel(title: "Банкоматы"), atmCheckButton])
        let infoboxView = createHorizontalStackViewFor([createLabel(title: "Инфокиоски"), infoboxCheckButton])
        let filialView = createHorizontalStackViewFor([createLabel(title: "Филиалы"), filialCheckButton])

        let stackView = UIStackView(arrangedSubviews: [atmView, infoboxView, filialView])
        let spacing: CGFloat = 5.0
        stackView.spacing = spacing
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fillEqually

        return stackView
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 5
        isHidden = true
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    private func createCheckboxButtonForType(_ type: BankElements) -> CheckboxButton {
        let button = CheckboxButton(type: .custom)
        button.setupBankElementType(type)
        button.addTarget(self, action: #selector(updateSelectedTypesFrom), for: .touchUpInside)

        return button
    }

    @objc private func updateSelectedTypesFrom(_ button: CheckboxButton) {
        if let index = selectedTypes.firstIndex(where: { $0 == button.elementType }) {
            selectedTypes.remove(at: index)
        } else {
            selectedTypes.append(button.elementType)
        }
    }

    private func createHorizontalStackViewFor(_ views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        let spacing: CGFloat = 5.0
        stackView.spacing = spacing
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing

        return stackView
    }

    private func createLabel(title: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = 1
        label.text = title

        return label
    }
}
