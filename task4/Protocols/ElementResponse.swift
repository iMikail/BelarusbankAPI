//
//  ElementResponse.swift
//  task4
//
//  Created by Misha Volkov on 10.01.23.
//

protocol ElementResponse {
    var id: String { get }
    var latitude: String { get }
    var longitude: String { get }
    var installPlace: String { get }
    var workTime: String { get }
    var elementType: BankElements { get }
    //Разделить atm,infobox / filial?
    var currency: String { get }
    var cashIn: String { get }
    var phoneInfo: String { get }
}
