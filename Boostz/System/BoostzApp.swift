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
    
    init() {
        setupAlbyKit()
    }
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
        }
    }
    
    private func setupAlbyKit() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let clientID = infoDictionary["AlbyClientID"] as? String,
              let clientSecret = infoDictionary["AlbyClientSecret"] as? String,
              let redirectURI = infoDictionary["OauthRedirectUri"] as? String else { fatalError("AlbyKit clientID, clientSecret, and oauth redirectURI are not properly set in your User.xcconfig file") }
        AlbyKit.setup(api: .prod, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
    }
}
