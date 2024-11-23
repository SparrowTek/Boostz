//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation
import Vault

@Observable
@MainActor
public class AppState {
    enum Route: Int, Identifiable {
        case wallet
        case setup
        case config
        
        var id: Int { rawValue }
    }
    
    var route: Route = .wallet //.setup
    var triggerDataSync = false
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    
    init() {}
    
    func onOpenURL(_ url: URL) async {
        guard url.scheme == "boostz" else { return }
        
        switch url.host() {
        default:
            break
        }
    }
}
