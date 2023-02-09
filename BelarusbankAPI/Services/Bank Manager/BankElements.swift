//
//  BankElements.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 10.01.23.
//

enum BankElements: Int, CaseIterable {
    case atm
    case infobox
    case filial

    var apiLink: String {
        switch self {
        case .atm: return "https://belarusbank.by/api/atm"
        case .infobox: return "https://belarusbank.by/api/infobox"
        case .filial: return  "https://belarusbank.by/api/filials_info"
        }
    }

    var elementName: String {
        switch self {
        case .atm: return "Банкомат"
        case .infobox: return "Инфокиоск"
        case .filial: return "Филиал"
        }
    }

    var imageName: String {
        switch self {
        case .atm: return "atm"
        case .infobox: return "infobox"
        case .filial: return "filial"
        }
    }
}
