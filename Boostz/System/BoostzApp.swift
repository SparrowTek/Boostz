//
//  BoostzApp.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI
import AlbyKit

@main
@MainActor
struct BoostzApp: App {
    @State private var state = AppState()
    @State private var albyKit = AlbyKit()
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .environment(state)
                .environment(albyKit)
                .setTheme()
                .task { await setupAlbyKit() }
        }
    }
    
    private func setupAlbyKit() async {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let clientID = infoDictionary["AlbyClientID"] as? String,
              let clientSecret = infoDictionary["AlbyClientSecret"] as? String else { fatalError("AlbyKit clientID, clientSecret, and oauth redirectURI are not properly set in your User.xcconfig file") }
        await AlbyKit.setup(api: Build.shared.environment.alby, clientID: clientID, clientSecret: clientSecret, redirectURI: "boostz://alby")
        await state.setAlbyDelegate()
    }
}
