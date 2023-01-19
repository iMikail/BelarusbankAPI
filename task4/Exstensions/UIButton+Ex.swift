//
//  UIButton+Ex.swift
//  task4
//
//  Created by Misha Volkov on 7.01.23.
//

import UIKit

extension UIButton {
    func requestingState(_ enable: Bool) {
        guard let imageView = imageView else { return }

        isEnabled = !enable
        if enable {
            UIView.animate(withDuration: 1.0, delay: .zero, options: [.repeat]) {
                imageView.transform = CGAffineTransform(rotationAngle: .pi)
            }
        } else {
            imageView.transform = .identity
            imageView.layer.removeAllAnimations()
        }
    }

    func setupRefreshConfigurating() {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Обновить"
        configuration.attributedTitle?.font = UIFont.systemFont(ofSize: 15.0)
        configuration.image = UIImage(systemName: "arrow.triangle.2.circlepath")
        configuration.imagePadding = 5.0

        self.configuration = configuration
    }
}
