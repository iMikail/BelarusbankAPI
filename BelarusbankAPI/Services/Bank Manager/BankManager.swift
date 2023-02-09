//
//  BankManager.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 9.01.23.
//

import Foundation

protocol BankManagerDelegate: AnyObject {
    func bankElementsDidUpdated(_ elements: [ElementResponse])
}

final class BankManager {
    // MARK: - Properties
    weak var delegate: BankManagerDelegate?

    private var atms = ATMResponse()
    private var infoboxes = InfoboxResponse()
    private var filials = FilialResponse()

    var allBankElements: [ElementResponse] { return atms + infoboxes + filials }

    // MARK: - Functions
    func fetchElement(_ type: BankElements, id: String) -> ElementDescription? {
        switch type {
        case .atm:
            return atms.first(where: { $0.itemId == id })
        case .infobox:
            return infoboxes.first(where: { $0.itemId == id })
        case .filial:
            return filials.first(where: { $0.itemId == id })
        }
    }

    // MARK: Updating functions
    func updateElements(_ elements: [DataForElement]) {
        elements.forEach { (data, type) in
            switch type {
            case .atm:
                getAtms(fromData: data)
            case .infobox:
                getInfobox(fromData: data)
            case .filial:
                getFillials(fromData: data)
            }
        }
        delegate?.bankElementsDidUpdated(allBankElements)
    }

    private func getAtms(fromData data: Data) {
        do {
            atms = try ATMResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    private func getInfobox(fromData data: Data) {
        do {
            infoboxes = try InfoboxResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    private func getFillials(fromData data: Data) {
        do {
            filials = try FilialResponse(data: data)
        } catch let error {
            print(error)
        }
    }
}
