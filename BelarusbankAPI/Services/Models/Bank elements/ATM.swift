//
//  ATM.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 4.01.23.
//

import Foundation

typealias ATMResponse = [ATM]

struct ATM: Codable {
    let id: String?
    let area: String?
    let cityType: String?
    let city: String?
    let addressType: String?
    let address: String?
    let house: String?
    let installPlace: String?
    let workTime: String?
    let gpsX: String?
    let gpsY: String?
    let installPlaceFull: String?
    let workTimeFull: String?
    let atmType: String?
    let atmError: String?
    let currency: String?
    let cashIn: String?
    let atmPrinter: String?

    enum CodingKeys: String, CodingKey {
        case id, area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case workTime = "work_time"
        case gpsX = "gps_x"
        case gpsY = "gps_y"
        case installPlaceFull = "install_place_full"
        case workTimeFull = "work_time_full"
        case atmType = "ATM_type"
        case atmError = "ATM_error"
        case currency
        case cashIn = "cash_in"
        case atmPrinter = "ATM_printer"
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(ATM.self, from: data)
    }
}

extension ATM: TerminalElementResponse, ElementDescription {
    var itemId: String { return id ?? "" }
    var latitude: String { return gpsX ?? "" }
    var longitude: String { return gpsY ?? "" }
    var itemCity: String { return city ?? "" }
    var itemInstallPlace: String { return installPlace ?? "" }
    var itemWorkTime: String { return workTime ?? "" }
    var itemCurrency: String { return currency ?? "" }
    var itemCashIn: String { return cashIn ?? "" }
    var elementType: BankElements { return .atm }

    func arrayDescriptions() -> [String] {
        var descriptions = [String]()

        descriptions.append("id банкомата: \(id ?? "")")
        descriptions.append("Область: \(area ?? "")")
        descriptions.append("Тип населённого пункта: \(cityType ?? "")")
        descriptions.append("Название населённого пункта: \(city ?? "")")
        descriptions.append("Тип улицы: \(addressType ?? "")")
        descriptions.append("Название улицы: \(address ?? "")")
        descriptions.append("Дом: \(house ?? "")")
        descriptions.append("Место установки: \(installPlace ?? "")")
        descriptions.append("Режим работы банкомата: \(workTime ?? "")")
        descriptions.append("Координата широты: \(latitude)")
        descriptions.append("Координата долготы: \(longitude)")
        descriptions.append("Пояснение места установки: \(installPlaceFull ?? "")")
        let weekTime = (workTimeFull?.components(separatedBy: ",").joined(separator: "\n") ?? "")
        descriptions.append("Режим работы банкомата:\n\(weekTime)")
        descriptions.append("Тип банкомата: \(atmType ?? "")")
        descriptions.append("Исправность банкомата: \(atmError ?? "")")
        descriptions.append("Выдаваемая валюта: \(currency ?? "")")
        descriptions.append("Наличие купюроприемника: \(cashIn ?? "")")
        descriptions.append("Возможность печати чека: \(atmPrinter ?? "")")

        return descriptions
    }
}
