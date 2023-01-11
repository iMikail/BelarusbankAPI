//
//  ATMAnnotationView.swift
//  task4
//
//  Created by Misha Volkov on 4.01.23.
//

import MapKit

protocol ATMViewCellDelegate: AnyObject {
    func fetchMoreInfo(forAtmId id: String)
}

final class ElementAnnotationView: MKMarkerAnnotationView {
    static let identifier = "atm"

    // MARK: - Properties
    internal var atmAnnotation: ElementAnnotation? {
        didSet {
            setupInfo()
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

            if let atmAnnotation = self.atmAnnotation {
                self.delegate?.fetchMoreInfo(forAtmId: atmAnnotation.id)
            }
        }
        button.addAction(action, for: .touchUpInside)

        return button
    }()

    private lazy var detailView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailLabel, detailButton])
        stackView.axis = .vertical
        let spacing: CGFloat = 5.0
        stackView.spacing = spacing
        stackView.layoutMargins = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
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
        if let atmAnnotation = atmAnnotation {
            let workTime = "Время работы: \(atmAnnotation.workTime)"
            let currency = "Валюта: \(atmAnnotation.currency)"
            let cashIn = "Приём наличных: \(atmAnnotation.cashIn)"
            detailLabel.text = "\(atmAnnotation.installPlace)\n\(workTime)\n\(currency)\n\(cashIn)"
        }
    }
}
