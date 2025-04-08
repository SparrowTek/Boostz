//
//  NWPathMonitor.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/31/23.
//

import Network

extension NWPathMonitor {
    func paths() -> AsyncStream<NWPath> {
        AsyncStream { continuation in
            pathUpdateHandler = { continuation.yield($0) }
            continuation.onTermination = { [weak self] _ in self?.cancel() }
            start(queue: DispatchQueue(label: "com.sparrowtek.Avocadough.NSPathMonitor.paths"))
        }
    }
}
