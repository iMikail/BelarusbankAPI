//
//  ATMAnnotationView.swift
//  task4
//
//  Created by Misha Volkov on 4.01.23.
//

import MapKit

protocol ATMViewCellDelegate: AnyObject {
    func fetchMoreInfoForElement(_ type: BankElements, id: String)
}

final class ElementAnnotationView: MKMarkerAnnotationView {
    static let identifier = "element"

    // MARK: - Properties
    internal var elementAnnotation: ElementAnnotation? {
        didSet {
            setupInfo()
            configuratingPin()
        }
    }
    weak var delegate: ATMViewCellDelegate?

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

            if let annotation = self.elementAnnotation {
                self.delegate?.fetchMoreInfoForElement(annotation.elementType, id: annotation.id)
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

// MARK: - Funcs
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
        calloutOffset = CGPoint(x: -5, y: 5)
        detailCalloutAccessoryView = detailView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInfo() {
        guard let annotation = elementAnnotation else { return }

        var workTime = "Время работы:"
        var result = "\(annotation.elementType.elementName)\n\(annotation.installPlace)"

        if annotation.elementType == .filial {
            workTime += "\n" + annotation.workTime.split(separator: "|").joined(separator: "\n")
            let phoneNumber = "Номер телефона: \(annotation.phoneInfo)"
            result += "\n\(workTime)\n\(phoneNumber)"
        } else {
            workTime += " \(annotation.workTime)"
            let currency = "Валюта: \(annotation.currency)"
            let cashIn = "Приём наличных: \(annotation.cashIn)"
            result += "\n\(workTime)\n\(currency)\n\(cashIn)"
        }
        detailLabel.text = result
        elementImageView.image = UIImage(named: annotation.elementType.imageName)
    }

    private func configuratingPin() {
        markerTintColor = .secondarySystemBackground
        glyphTintColor = .systemGreen
        if let firstChar = elementAnnotation?.elementType.elementName.first {
            glyphText = String(firstChar)
        }
    }
}
