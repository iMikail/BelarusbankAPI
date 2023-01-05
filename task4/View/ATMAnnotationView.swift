//
//  ATMAnnotationView.swift
//  task4
//
//  Created by Misha Volkov on 4.01.23.
//

import MapKit

final class ATMAnnotationView: MKMarkerAnnotationView {
    static let identifier = "atm"

    internal var atmAnnotation: ATMAnnotation? {
        didSet {
            setupInfo()
        }
    }

    internal var idHandler: (_ id: String) -> Void = { _ in }

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
                self.idHandler(atmAnnotation.id)
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

//    private lazy var closeButton: UIButton = {
//        let action = UIAction { [weak self] _ in
//            self?.setSelected(false, animated: true)
//        }
//        let button = UIButton(type: .close, primaryAction: action)
//
//        return button
//    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
        calloutOffset = CGPoint(x: -5, y: 5)
        detailCalloutAccessoryView = detailView
        //rightCalloutAccessoryView = closeButton //?
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
