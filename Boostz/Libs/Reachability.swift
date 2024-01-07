//
//  Reachability.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/31/23.
//

import Network
import SwiftUI

@Observable
class Reachability {
    enum ConnectionState {
        case notReachable
        case degradedPerformance
        case good
    }
    
    var connectionState: ConnectionState = .good
    
    func startMonitoring() async {
        let monitor = NWPathMonitor()
        for await path in monitor.paths() {
            evaluatePath(path)
        }
    }
    
    private func evaluatePath(_ path: NWPath) {
        withAnimation(.easeInOut(duration: 1.0)) {
            if path.status == .satisfied {
                connectionState = .good
            } else {
                connectionState = .notReachable
            }
        }
    }
}
