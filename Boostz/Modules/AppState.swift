//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation
import Vault
import AlbyKit

@Observable
public class AppState {
    enum Route: Int, Identifiable {
        case wallet
        case auth
        case config
        
        var id: Int { rawValue }
    }
    
    var route: Route = .auth
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var authState = AuthState(parentState: self)
    
    init() {
        AlbyKit.setDelegate(self)
        checkAlbyTokenStatus()
    }
    
    private func checkAlbyTokenStatus() {
        guard let accessToken = try? Vault.getPrivateKey(keychainConfiguration: .albyToken),
              let refreshToken = try? Vault.getPrivateKey(keychainConfiguration: .albyRefreshToken) else { return }
        AlbyKit.set(accessToken: accessToken, refreshToken: refreshToken)
        route = .config
    }
    
    func onOpenURL(_ url: URL) async {
        print("URL: \(url)") // TODO: delete print statement
        guard url.scheme == "boostz" else { return }
        
        switch url.host() {
        case "alby":
            getAlbyToken(url: url)
        default:
            break
        }
    }
    
    private func getAlbyToken(url: URL) {
        guard let query = url.query() else { return }
        let code = query.replacingOccurrences(of: "code=", with: "")
        authState.dismissSheet()
        authState.albyCode = code
    }
    
    func saveAlbyToken(_ token: Token) {
        do {
            try Vault.savePrivateKey(token.accessToken, keychainConfiguration: .albyToken)
            try Vault.savePrivateKey(token.refreshToken, keychainConfiguration: .albyRefreshToken)
            AlbyKit.set(accessToken: token.accessToken, refreshToken: token.refreshToken)
            route = .config
        } catch {
            // TODO: handle failed save
        }
    }
    
    func logout() {
        do {
            try deleteAlbyTokens()
            route = .auth
        } catch {
            // TODO: Alert user that logout failed
        }
    }
    
    private func deleteAlbyTokens() throws {
        try Vault.deletePrivateKey(keychainConfiguration: .albyToken)
        try Vault.deletePrivateKey(keychainConfiguration: .albyRefreshToken)
    }
}

extension AppState: AlbyKitDelegate {
    public func tokenUpdated(_ token: Token) {
        print("TOKEN UPDATED: \(token)")
        try? Vault.savePrivateKey(token.accessToken, keychainConfiguration: .albyToken)
        try? Vault.savePrivateKey(token.refreshToken, keychainConfiguration: .albyRefreshToken)
    }
    
    public func unautherizedUser() {
        logout()
    }
}
