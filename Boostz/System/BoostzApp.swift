//
//  BoostzApp.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI

@main
@MainActor
struct BoostzApp: App {
    @State private var reachability = Reachability()
    @State private var nwc = NWC()
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .setTheme()
                .setupAppState()
                .setupModel()
                .environment(\.nwc, nwc)
                .environment(\.reachability, reachability)
        }
    }
}
