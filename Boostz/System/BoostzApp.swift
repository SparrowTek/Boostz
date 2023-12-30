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
    @State private var url: URL?
    @State private var onOpenURLTrigger = PlainTaskTrigger()
    
    init() {
        setupAlbyKit()
    }
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .environment(state)
                .environment(albyKit)
                .setTheme()
                .onOpenURL { url = $0 }
                .onChange(of: url, triggerOnOpenUrl)
                .task($onOpenURLTrigger) { await openUrl() }
        }
    }
    
    private func triggerOnOpenUrl() {
        onOpenURLTrigger.trigger()
    }
    
    private func openUrl() async {
        guard let url else { return }
        await state.onOpenURL(url)
    }
    
    private func setupAlbyKit() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let clientID = infoDictionary["AlbyClientID"] as? String,
              let clientSecret = infoDictionary["AlbyClientSecret"] as? String,
              let redirectURI = infoDictionary["OauthRedirectUri"] as? String else { fatalError("AlbyKit clientID, clientSecret, and oauth redirectURI are not properly set in your User.xcconfig file") }
        AlbyKit.setup(api: Build.shared.environment.alby, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
    }
}
