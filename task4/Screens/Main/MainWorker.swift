//
//  MainWorker.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

class MainService {
    private let networkService = NetworkService()
    private let coreDataManager = CoreDataManager()

    private var isFirstRequest = true

    func updateData(completion: ((Bool, [DataForElement]?, [ErrorForElement]?) -> Void)? = nil) {
        if isFirstRequest {
            isFirstRequest = false
            guard NetworkMonitor.shared.isConnected else {
                let dataArray = coreDataManager.fetchStoreData(forTypes: BankElements.allCases)
                completion?(false, dataArray, nil)
                return
            }
            getData { (dataArray, errors) in
                completion?(true, dataArray, errors)
            }
        } else {
            guard NetworkMonitor.shared.isConnected else {
                completion?(false, nil, nil)
                return
            }

            BankElements.allCases.forEach {
                getData(forTypes: [$0]) { (dataArray, errors) in
                    if errors == nil {
                        completion?(true, dataArray, nil)
                    } else {
                        completion?(true, nil, nil)
                    }
                }
            }
        }
    }

    private func getData(forTypes types: [BankElements] = BankElements.allCases,
                         completion: (([DataForElement]?, [ErrorForElement]?) -> Void)? = nil) {
        networkService.getData(forTypes: types) { [weak self] (dataArray, errors) in
            guard let self = self else { return }

            self.coreDataManager.updateData(dataArray)

            if errors.isEmpty {
                completion?(dataArray, nil)
            } else {
                var errorTypes = [BankElements]()
                errors.forEach { (_, type) in
                    errorTypes.append(type)
                }
                let storeData = self.coreDataManager.fetchStoreData(forTypes: errorTypes)
                completion?(dataArray + storeData, errors)
            }
        }
    }
}
