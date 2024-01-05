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
        checkAlbyTokenStatus()
    }
    
    private func checkAlbyTokenStatus() {
        guard let token = try? Vault.getPrivateKey(keychainConfiguration: .albyToken), !token.isEmpty else { return }
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
            route = .config
        } catch {
            // TODO: handle failed save
        }
    }
    
    func logout() {
        do {
            try Vault.deletePrivateKey()
            try deleteAlbyTokens()
            route = .auth
        } catch {
            // TODO: Alert user that logout failed
        }
    }
    
    func deleteAlbyTokens() throws {
        try Vault.deletePrivateKey(keychainConfiguration: .albyToken)
        try Vault.deletePrivateKey(keychainConfiguration: .albyRefreshToken)
    }
}
