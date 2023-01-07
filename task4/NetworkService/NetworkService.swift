//
//  NetworkService.swift
//  task4
//
//  Created by Misha Volkov on 28.12.22.
//

import Foundation

final class NetworkService {

    private init() {}

    private static let link = "https://belarusbank.by/api/atm"

    internal static func getData(completion: @escaping (Data?, Error?, Bool) -> Void) {
        guard let url = URL(string: link) else {
            let error = URLError(.badURL)
            completion(nil, error, true)
            return
        }

        let session = URLSession.shared
        session.dataTask(with: URLRequest(url: url, timeoutInterval: 30)) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error, true)
                    return
                }

                if let data = data {
                    completion(data, nil, true)
                } else {
                    completion(nil, nil, true)
                }
            }
        }.resume()
    }
}
