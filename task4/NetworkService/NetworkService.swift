//
//  NetworkService.swift
//  task4
//
//  Created by Misha Volkov on 28.12.22.
//

import Foundation

final class NetworkService {

    private init() {}

    internal static func getData(forBankElement element: BankElements,
                                 completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: element.apiLink) else {
            let error = URLError(.badURL)
            completion(nil, error)
            return
        }

        let session = URLSession.shared
        session.dataTask(with: URLRequest(url: url, timeoutInterval: 30)) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                if let data = data {
                    completion(data, nil)
                } else {
                    completion(nil, nil)
                }
            }
        }.resume()
    }
}
