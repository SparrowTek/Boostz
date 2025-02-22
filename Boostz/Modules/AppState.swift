//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI
import Vault
import NostrSDK

@Observable
@MainActor
public class AppState {
    enum Route: Int, Identifiable {
        case wallet
        case setup
        case config
        
        var id: Int { rawValue }
    }
    
    var route: Route = .setup
    var triggerDataSync = false
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var setupState = SetupState(parentState: self)
    
    func onOpenURL(_ url: URL) async {
        guard url.scheme == "boostz" else { return }
        
        switch url.host() {
        default:
            break
        }
    }
    
    func determineRoute() {
        try? Vault.deletePrivateKey(keychainConfiguration: .nwcSecret)
//        do {
//            let _ = try Vault.getPrivateKey(keychainConfiguration: .nwcSecret)
//            route = .config
//        } catch {
//            route = .setup
//        }
    }
    
    func walletSuccessfullyConnected() {
        route = .config
    }
    
    func configSuccessful() {
        route = .wallet
    }
    
    func saveInfo(_ info: GetInfoResponse) {
        configSuccessful()
    }
}
