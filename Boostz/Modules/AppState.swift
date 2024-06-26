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
@MainActor
public class AppState {
    enum Route: Int, Identifiable {
        case wallet
        case auth
        case config
        
        var id: Int { rawValue }
    }
    
    var route: Route = .auth
    var triggerDataSync = false
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var authState = AuthState(parentState: self)
    
    init() {
        checkAlbyTokenStatus()
    }
    
    func setAlbyDelegate() async {
        await AlbyKit.setDelegate(self)
    }
    
    private func checkAlbyTokenStatus() {
        guard let accessToken = try? Vault.getPrivateKey(keychainConfiguration: .albyToken), !accessToken.isEmpty else { return }
        route = .config
    }
    
    func onOpenURL(_ url: URL) async {
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
            guard let accessToken = token.accessToken, let refreshToken = token.refreshToken else { return } // TODO: handle this error state
            try Vault.savePrivateKey(accessToken, keychainConfiguration: .albyToken)
            try Vault.savePrivateKey(refreshToken, keychainConfiguration: .albyRefreshToken)
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
    
    // MARK: update wallet state
    func setAccountSummary(_ accountSummary: AccountSummary) {
        walletState.accountSummary = accountSummary
    }
    
    func setAccountBalance(_ accountBalance: AccountBalance) {
        walletState.accountBalance = accountBalance
    }
    
    func setMe(_ me: PersonalInformation) {
        walletState.me = me
    }
}

extension AppState: AlbyKitDelegate {
    public func tokenUpdated(_ token: Token) {
        guard let accessToken = token.accessToken, let refreshToken = token.refreshToken else { return } // TODO: handle this error state
        try? Vault.savePrivateKey(accessToken, keychainConfiguration: .albyToken)
        try? Vault.savePrivateKey(refreshToken, keychainConfiguration: .albyRefreshToken)
    }
    
    public func unautherizedUser() {
        logout()
    }
    
    public func reachabilityNormalPerformance() {
        walletState.reachability.connectionState = .good
    }
    
    public func reachabilityDegradedNetworkPerformanceDetected() {
        walletState.reachability.connectionState = .degradedPerformance
    }
    
    public func getAccessToken() -> String? {
        try? Vault.getPrivateKey(keychainConfiguration: .albyToken)
    }
    
    public func getFreshToken() -> String? {
        try? Vault.getPrivateKey(keychainConfiguration: .albyRefreshToken)
    }
}
