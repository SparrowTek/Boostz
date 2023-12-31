//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation
import Vault

@Observable
public class AppState {
    enum Route: Int, Identifiable {
        case wallet
        case auth
        
        var id: Int { rawValue }
    }
    
    var route: Route = .auth
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var authState = AuthState(parentState: self)
    
    init() {
        setupVault()
        checkAlbyTokenStatus()
    }
    
    private func checkAlbyTokenStatus() {
        guard let token = try? Vault.getPrivateKey(), !token.isEmpty else { return }
        route = .wallet
    }
    
    func onOpenURL(_ url: URL) async {
        guard url.scheme == "boostz" else { return }
        
        switch url.host() {
        case "alby":
            saveAlbyToken(url: url)
        default:
            break
        }
    }
    
    private func saveAlbyToken(url: URL) {
        guard let token = url.query() else { return }
        let modifiedToken = token.replacingOccurrences(of: "code=", with: "")
        
        do {
            try Vault.savePrivateKey(modifiedToken)
            authState.dismissSheet()
            route = .wallet
        } catch {
            // TODO: alert user to try again
        }
    }
    
    func logout() {
        do {
            try Vault.deletePrivateKey()
            route = .auth
            // TODO: delete any app stored data here
        } catch {
            // TODO: Alert user that logout failed
        }
    }
    
    private func setupVault() {
        Vault.configure(KeychainConfiguration(serviceName: "boostz", accessGroup: nil, accountName: "albyToken"))
//#if DEBUG
//Vault.configure(KeychainConfiguration(serviceName: "boostz", accessGroup: nil, accountName: "albyToken"))
//#else
        // TODO: figure out how to set the accessGroup with the xcconfig
//Vault.configure(KeychainConfiguration(serviceName: "boostz", accessGroup: accessGroup, accountName: "mfl cookie"))
//#endif
    }
}
