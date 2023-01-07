//
//  UIButton+Ex.swift
//  task4
//
//  Created by Misha Volkov on 7.01.23.
//

import UIKit

extension UIButton {

    internal func requestingState(_ enable: Bool) {
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
}
