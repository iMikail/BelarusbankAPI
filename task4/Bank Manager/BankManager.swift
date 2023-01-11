//
//  BankManager.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import UIKit

protocol BankManagerDelegate: AnyObject {
    func atmsDidUpdate()
    func infoboxDidUpdate()
    func filialsDidUpdate()
}

final class BankManager: NSObject {
    // MARK: - Properties
    weak var delegate: BankManagerDelegate?
    internal var atms = ATMResponse()
    internal var infoboxes = InfoboxResponse()
    internal var filials = FilialResponse()
    internal var allBankElements: [ElementResponse] { return atms + infoboxes + filials }

    internal var sortedAtms = [ATMResponse]()

    // MARK: - Functions
    internal func updateElements(_ element: BankElements, fromData data: Data) {
            switch element {
            case .atm: updateAtms(fromData: data)
            case .infobox: updateInfobox(fromData: data)
            case .filial: updateFillials(fromData: data)
            }
    }

    private func updateAtms(fromData data: Data) {
        do {
            atms = try ATMResponse(data: data)
            delegate?.atmsDidUpdate()
            print("atms updated, \(atms.count)")//-
        } catch let error {
            print(error)
        }
    }

    private func updateInfobox(fromData data: Data) {
        do {
            infoboxes = try InfoboxResponse(data: data)
            delegate?.infoboxDidUpdate()
            print("infoboxes updated, \(infoboxes.count)")//-
        } catch let error {
            print(error)
        }
    }

    private func updateFillials(fromData data: Data) {
        do {
            filials = try FilialResponse(data: data)
            delegate?.filialsDidUpdate()
            print("filials updated, \(filials.count)")//-
        } catch let error {
            print(error)
        }
    }

    private func sortAtmsByCities() -> [ATMResponse] {
        var atms = atms
        var sortedAtms = [ATMResponse]()

        while !atms.isEmpty {
            var array = ATMResponse()
            let city = atms[0].city

            for atm in atms where atm.city == city {
                array.append(atm)
            }
            atms.removeAll { $0.city == city }
            sortedAtms.append(array)
        }

        return sortedAtms.map { $0.sorted { $0.id < $1.id } }
    }
}

// MARK: - UICollectionViewDataSource
extension BankManager: UICollectionViewDataSource {
//    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return sortedAtms.count
//    }

    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allBankElements.count
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ElementViewCell.identifier,
            for: indexPath) as? ElementViewCell else {
            return UICollectionViewCell()
        }

        cell.bankElement = allBankElements[indexPath.row]

        return cell
    }

//    internal func collectionView(_ collectionView: UICollectionView,
//                                 viewForSupplementaryElementOfKind kind: String,
//                                 at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let headerView = collectionView.dequeueReusableSupplementaryView(
//            ofKind: kind,
//            withReuseIdentifier: SectionHeaderView.identifier,
//            for: indexPath
//        ) as? SectionHeaderView else {
//            return UICollectionReusableView()
//        }
//
//        headerView.titleLabel.text = sortedAtms[indexPath.section].first?.city
//
//        return headerView
//    }
//
//    internal func collectionView(_ collectionView: UICollectionView,
//                                 layout collectionViewLayout: UICollectionViewLayout,
//                                 referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 40.0)
//    }
}
