//
//  Infobox.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import Foundation

typealias InfoboxResponse = [Infobox]

struct Infobox: Codable {
    let infoID: Int?
    let area: String?
    let cityType: String?
    let city: String?
    let addressType: String?
    let address: String?
    let house: String?
    let installPlace: String?
    let locationNameDesc: String?
    let workTime: String?
    let timeLong: String?
    let gpsX: String?
    let gpsY: String?
    let currency: String?
    let infType: String?
    let cashInExist: String?
    let cashIn: String?
    let typeCashIn: String?
    let infPrinter: String?
    let regionPlatej: String?
    let popolneniePlatej: String?
    let infStatus: String?

    enum CodingKeys: String, CodingKey {
        case infoID = "info_id"
        case area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case locationNameDesc = "location_name_desc"
        case workTime = "work_time"
        case timeLong = "time_long"
        case gpsX = "gps_x"
        case gpsY = "gps_y"
        case currency
        case infType = "inf_type"
        case cashInExist = "cash_in_exist"
        case cashIn = "cash_in"
        case typeCashIn = "type_cash_in"
        case infPrinter = "inf_printer"
        case regionPlatej = "region_platej"
        case popolneniePlatej = "popolnenie_platej"
        case infStatus = "inf_status"
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(Infobox.self, from: data)
    }
}

extension Infobox: ElementDescription {
    var itemId: String {
        if let id = infoID {
            return String(id)
        } else {
            return ""
        }
    }
    var latitude: String { return gpsX ?? "" }
    var longitude: String { return gpsY ?? "" }
    var itemCity: String { return city ?? "" }
    var itemInstallPlace: String { return installPlace ?? "" }
    var itemWorkTime: String { return workTime ?? "" }
    var itemCurrency: String { return currency ?? "" }
    var itemCashIn: String { return cashIn ?? "" }
    var itemPhoneInfo: String { return "" }
    var elementType: BankElements { return .infobox }

    func arrayDescriptions() -> [String] {
        var arrayDescriprions = [String]()

        Mirror(reflecting: self).children.forEach { child in
            if let property = child.label, let value = child.value as? String {
                arrayDescriprions.append("\(property): \(value)")
            }
        }

        return arrayDescriprions
    }
}
