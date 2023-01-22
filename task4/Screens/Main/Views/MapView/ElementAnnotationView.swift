//
//  ATMAnnotationView.swift
//  task4
//
//  Created by Misha Volkov on 4.01.23.
//

import MapKit

protocol ElementAnnotationViewDelegate: AnyObject {
    func fetchMoreInfoForElement(_ type: BankElements, id: String)
}

final class ElementAnnotationView: MKMarkerAnnotationView {
    static let identifier = "element"

    // MARK: - Properties
    weak var delegate: ElementAnnotationViewDelegate?

    var elementAnnotation: ElementAnnotation? {
        didSet {
            setupInfo()
            configuratingPin()
        }
    }

    // MARK: - Views
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13.0)

        return label
    }()

    private lazy var detailButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("Подробнее", for: .normal)
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }

            if let element = self.elementAnnotation?.element {
                self.delegate?.fetchMoreInfoForElement(element.elementType, id: element.itemId)
            }
        }
        button.addAction(action, for: .touchUpInside)

        return button
    }()

    private lazy var detailView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [elementImageView, detailLabel, detailButton])
        stackView.axis = .vertical
        let spacing: CGFloat = 5.0
        stackView.spacing = spacing
        stackView.layoutMargins = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }()

    private lazy var elementImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .left

        return imageView
    }()

    // MARK: - Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
        calloutOffset = CGPoint(x: -5, y: 5)
        detailCalloutAccessoryView = detailView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    private func setupInfo() {
        guard let element = elementAnnotation?.element else { return }

        var workTime = "Время работы:"
        var result = "\(element.elementType.elementName)\n\(element.itemInstallPlace)"

        if let filial = element as? FilialElementResponse {
            workTime += "\n" + filial.itemWorkTime.split(separator: "|").joined(separator: "\n")
            let phoneNumber = "Номер телефона:\n\(filial.itemPhoneInfo)"
            result += "\n\(workTime)\n\(phoneNumber)"
        } else if let terminal = element as? TerminalElementResponse {
            workTime += "\n\(terminal.itemWorkTime)"
            let currency = "Валюта: \(terminal.itemCurrency)"
            let cashIn = "Приём наличных: \(terminal.itemCashIn)"
            result += "\n\(workTime)\n\(currency)\n\(cashIn)"
        }
        detailLabel.text = result
        elementImageView.image = UIImage(named: element.elementType.imageName)
    }

    private func configuratingPin() {
        markerTintColor = .secondarySystemBackground
        glyphTintColor = .systemGreen
        if let firstChar = elementAnnotation?.element.elementType.elementName.first {
            glyphText = String(firstChar)
        }
    }
}
