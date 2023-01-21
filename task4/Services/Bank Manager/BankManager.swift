//
//  BankManager.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import UIKit

protocol BankManagerDelegate: AnyObject {
    func bankElementsDidUpdated(_ elements: [ElementResponse])
}

final class BankManager: NSObject {
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
                updateAtms(fromData: data)
            case .infobox:
                updateInfobox(fromData: data)
            case .filial:
                updateFillials(fromData: data)
            }
        }
        delegate?.bankElementsDidUpdated(allBankElements)
    }

    private func updateAtms(fromData data: Data) {//generic
        do {
            atms = try ATMResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    private func updateInfobox(fromData data: Data) {
        do {
            infoboxes = try InfoboxResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    private func updateFillials(fromData data: Data) {
        do {
            filials = try FilialResponse(data: data)
        } catch let error {
            print(error)
        }
    }
}
