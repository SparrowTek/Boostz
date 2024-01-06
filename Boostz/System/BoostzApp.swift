//
//  BoostzApp.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI
import AlbyKit

@main
struct BoostzApp: App {
    @State private var state = AppState()
    @State private var albyKit = AlbyKit()
    
    init() {
        setupAlbyKit()
    }
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .environment(state)
                .environment(albyKit)
                .setTheme()
                .onOpenURL()
        }
    }
    
    private func setupAlbyKit() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let clientID = infoDictionary["AlbyClientID"] as? String,
              let clientSecret = infoDictionary["AlbyClientSecret"] as? String else { fatalError("AlbyKit clientID, clientSecret, and oauth redirectURI are not properly set in your User.xcconfig file") }
        AlbyKit.setup(api: Build.shared.environment.alby, clientID: clientID, clientSecret: clientSecret, redirectURI: "boostz://alby")
    }
}
