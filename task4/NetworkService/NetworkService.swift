//
//  NetworkService.swift
//  task4
//
//  Created by Misha Volkov on 28.12.22.
//

import Foundation

typealias DataForElement = (data: Data, type: BankElements)
typealias ErrorForElement = (error: Error, type: BankElements)

final class NetworkService {
    private var dataArray = [DataForElement]()
    private var errors = [ErrorForElement]()

    internal func getDataForTypes(_ types: [BankElements],
                                  completion: @escaping ([DataForElement], [ErrorForElement]) -> Void) {
        let group = DispatchGroup()
        for type in types {
            group.enter()
            print("\(type) enter")
            fetchData(forBankElement: type) {
                group.leave()
                print("\(type) leave")//-
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            print(self.dataArray, self.errors)//-
            completion(self.dataArray, self.errors)
            self.dataArray = []
            self.errors = []
        }
    }

    private func fetchData(forBankElement element: BankElements, completion: @escaping () -> Void) {
        guard let url = URL(string: element.apiLink) else {
            let error = URLError(.badURL)
            errors.append((error, element))
            completion()
            return
        }

        let session = URLSession.shared
        session.dataTask(with: URLRequest(url: url, timeoutInterval: 30)) { [weak self] (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errors.append((error, element))
                    completion()
                    return
                }

                if let data = data {
                    self?.dataArray.append((data, element))
                }
                completion()
            }
        }.resume()
    }
}
