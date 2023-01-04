//
//  ATM.swift
//  task4
//
//  Created by Misha Volkov on 4.01.23.
//

import Foundation

typealias ATMResponse = [ATM]

struct ATM: Codable {
    let id: String
    let area: String
    let cityType: String
    let city: String
    let addressType: String
    let address: String
    let house: String
    let installPlace: String
    let workTime: String
    let latitude: String
    let longitude: String
    let installPlaceFull: String
    let workTimeFull: String
    let atmType: String
    let atmError: String
    let currency: String
    let cashIn: String
    let atmPrinter: String

    enum CodingKeys: String, CodingKey {
        case id, area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case workTime = "work_time"
        case latitude = "gps_x"
        case longitude = "gps_y"
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

extension Array where Element == ATMResponse.Element {
    init(data: Data) throws {
        self = try JSONDecoder().decode(ATMResponse.self, from: data)
    }
}
