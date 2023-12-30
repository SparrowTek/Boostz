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
        case setup
        
        var id: Int { rawValue }
    }
    
    var route: Route = .setup
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var setupState = SetupState(parentState: self)
    
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
            setupState.dismissSheet()
            route = .wallet
        } catch {
            // TODO: alert user to try again
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
