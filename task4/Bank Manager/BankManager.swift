//
//  BankManager.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import UIKit

protocol BankManagerDelegate: AnyObject {
    func atmsDidUpdate()
}

final class BankManager: NSObject {
    weak var delegate: BankManagerDelegate?
    internal var atms = ATMResponse() {
        didSet {
            delegate?.atmsDidUpdate()
            sortedAtms = sortAtmsByCities()
        }
    }
    internal var sortedAtms = [ATMResponse]()

    internal func updateAtms(fromData data: Data) {
        do {
            atms = try ATMResponse(data: data)
        } catch let error {
            print(error.localizedDescription)
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
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sortedAtms.count
    }

    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedAtms[section].count
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ATMViewCell.identifier,
            for: indexPath) as? ATMViewCell else {
            return UICollectionViewCell()
        }

        cell.atm = sortedAtms[indexPath.section][indexPath.row]

        return cell
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }

        headerView.titleLabel.text = sortedAtms[indexPath.section].first?.city

        return headerView
    }

    internal func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40.0)
    }
}
