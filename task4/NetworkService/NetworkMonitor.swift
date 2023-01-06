//
//  NetworkMonitor.swift
//  task4
//
//  Created by Misha Volkov on 6.01.23.
//

import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "InternetConnectionMonitor")

    internal private(set) var isConnected = false

    private init() {
        monitor = NWPathMonitor()
    }

    internal func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
        }
        monitor.start(queue: queue)
    }

    internal func stopMonitoring() {
        monitor.cancel()
    }
}
