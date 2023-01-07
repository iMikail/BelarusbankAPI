//
//  DisplayType.swift
//  task4
//
//  Created by Misha Volkov on 7.01.23.
//

import UIKit

enum DisplayType: Int, CaseIterable {
    case map
    case list

    var title: String {
        switch self {
        case .map: return "Карта"
        case .list: return "Список"
        }
    }
}
