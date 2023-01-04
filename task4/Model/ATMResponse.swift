//
//  ATM.swift
//  task4
//
//  Created by Misha Volkov on 28.12.22.
//

import Foundation

// MARK: - ATMResponse
struct ATMResponse: Codable {
    let data: ATMData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(ATMResponse.self, from: data)
    }
}

// MARK: - ATMData
struct ATMData: Codable {
    let atm: [ATM]

    enum CodingKeys: String, CodingKey {
        case atm = "ATM"
    }
}

// MARK: - ATM
struct ATM: Codable {
    let atmID: String
    let type: String
    let baseCurrency: String
    let currency: String
    let cards: [String]
    let currentStatus: String
    let address: Address
    let services: [Service]
    let availability: Availability
    let contactDetails: ContactDetails

    enum CodingKeys: String, CodingKey {
        case atmID = "atmId"
        case type, baseCurrency, currency, cards, currentStatus
        case address = "Address"
        case services = "Services"
        case availability = "Availability"
        case contactDetails = "ContactDetails"
    }
}

// MARK: - Address
struct Address: Codable {
    let streetName, buildingNumber, townName, countrySubDivision, country, addressLine, description: String
    let geolocation: Geolocation

    enum CodingKeys: String, CodingKey {
        case streetName, buildingNumber, townName, countrySubDivision, country, addressLine, description
        case geolocation = "Geolocation"
    }
}

// MARK: - Geolocation
struct Geolocation: Codable {
    let geographicCoordinates: GeographicCoordinates

    enum CodingKeys: String, CodingKey {
        case geographicCoordinates = "GeographicCoordinates"
    }
}

struct GeographicCoordinates: Codable {
    let latitude, longitude: String
}

// MARK: - Service
struct Service: Codable {
    let serviceType: String
    let description: String
}

// MARK: - Availability
struct Availability: Codable {
    let access24Hours, isRestricted, sameAsOrganization: Bool
    let standardAvailability: StandardAvailability

    enum CodingKeys: String, CodingKey {
        case access24Hours, isRestricted, sameAsOrganization
        case standardAvailability = "StandardAvailability"
    }
}

// MARK: StandardAvailability
struct StandardAvailability: Codable {
    let day: [Day]

    enum CodingKeys: String, CodingKey {
        case day = "Day"
    }
}

// MARK: Day
struct Day: Codable {
    let dayCode: String
    let openingTime: String
    let closingTime: String
    let dayBreak: Break

    enum CodingKeys: String, CodingKey {
        case dayCode, openingTime, closingTime
        case dayBreak = "Break"
    }
}

// MARK: Break
struct Break: Codable {
    let breakFromTime: String
    let breakToTime: String
}

// MARK: - ContactDetails
struct ContactDetails: Codable {
    let phoneNumber: String
}
