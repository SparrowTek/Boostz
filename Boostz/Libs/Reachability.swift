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
    
    var isReachable = true
    
    func startMonitoring() async {
        let monitor = NWPathMonitor()
        for await path in monitor.paths() {
            evaluatePath(path)
        }
    }
    
    private func evaluatePath(_ path: NWPath) {
        withAnimation(.easeInOut(duration: 1.0)) { isReachable = path.status == .satisfied }
    }
}
