//
//  Array+Ex.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 11.01.23.
//

import Foundation

extension Array where Element == ATMResponse.Element {
    init(data: Data) throws {
        self = try JSONDecoder().decode(ATMResponse.self, from: data)
    }
}

extension Array where Element == InfoboxResponse.Element {
    init(data: Data) throws {
        self = try JSONDecoder().decode(InfoboxResponse.self, from: data)
    }
}

extension Array where Element == FilialResponse.Element {
    init(data: Data) throws {
        self = try JSONDecoder().decode(FilialResponse.self, from: data)
    }
}
