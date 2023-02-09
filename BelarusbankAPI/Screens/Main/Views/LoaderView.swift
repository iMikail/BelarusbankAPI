//
//  LoaderView.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 14.01.23.
//

import UIKit

final class LoaderView: UIActivityIndicatorView {

    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        isHidden = true
        hidesWhenStopped = true
        transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHidden(_ hidden: Bool) {
        if hidden {
            stopAnimating()
        } else {
            isHidden = hidden
            startAnimating()
        }
    }

    private func setupLoaderConfig() {
        isHidden = true
        hidesWhenStopped = true
        transform = CGAffineTransform(scaleX: 2, y: 2)
    }
}
