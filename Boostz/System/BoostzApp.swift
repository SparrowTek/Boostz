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
    @State private var state = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .setTheme()
                .environment(state)
        }
    }
}
