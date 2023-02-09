//
//  CheckboxButton.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 13.01.23.
//

import UIKit

final class CheckboxButton: UIButton {

    var elementType = BankElements.atm

    func setupBankElementType(_ type: BankElements) {
        elementType = type
        isSelected = true
        tintColor = elementType.color
        setImage(UIImage(systemName: "square"), for: .normal)
        setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addTarget(self, action: #selector(self.toggleCheckboxSelection), for: .touchUpInside)
    }

    @objc private func toggleCheckboxSelection() {
        isSelected = !isSelected
    }
}
