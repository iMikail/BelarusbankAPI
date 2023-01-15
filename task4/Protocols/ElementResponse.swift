//
//  ElementResponse.swift
//  task4
//
//  Created by Misha Volkov on 10.01.23.
//

protocol ElementResponse {
    var itemId: String { get }
    var itemCity: String { get }
    var latitude: String { get }
    var longitude: String { get }
    var itemInstallPlace: String { get }
    var itemWorkTime: String { get }
    var elementType: BankElements { get }
    var itemCurrency: String { get }
    var itemCashIn: String { get }
    var itemPhoneInfo: String { get }
}
