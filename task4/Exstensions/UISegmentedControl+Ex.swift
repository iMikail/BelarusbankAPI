//
//  UISegmentedControl+Ex.swift
//  task4
//
//  Created by Misha Volkov on 14.01.23.
//

import UIKit

extension UISegmentedControl {
    func setupConfigurating() {
        selectedSegmentIndex = DisplayType.map.rawValue
        setDividerImage(UIImage(systemName: "chevron.left.2"), forLeftSegmentState: .selected,
                                         rightSegmentState: .normal, barMetrics: .default)
        setDividerImage(UIImage(systemName: "chevron.right.2"), forLeftSegmentState: .normal,
                                         rightSegmentState: .selected, barMetrics: .default)
        tintColor = .label
    }
}
