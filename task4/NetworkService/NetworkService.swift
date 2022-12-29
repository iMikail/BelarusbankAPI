//
//  NetworkService.swift
//  task4
//
//  Created by Misha Volkov on 28.12.22.
//

import Foundation

final class NetworkService {

  private init() {}

  private static let link = "https://belarusbank.by/open-banking/v1.0/atms"

  internal static func getData(completion: @escaping (Data) -> Void) {
    guard let url = URL(string: link)
    else {
      print("urlInvalid")
      return
    }

    let session = URLSession.shared
    session.dataTask(with: URLRequest(url: url)) { (data, _, error) in
      if let error = error {
        print(error.localizedDescription)
        print("noInternetConnection")//?
        return
      }
      if let data = data {
        DispatchQueue.main.async {
          completion(data)
        }
      } else {
        return
      }
    }.resume()
  }
}
