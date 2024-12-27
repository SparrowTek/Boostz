//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI
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
    
    var route: Route = .setup
    var triggerDataSync = false
    private let nwc: NWC
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var setupState = SetupState(parentState: self, nwc: nwc)
    
    init(nwc: NWC) {
        self.nwc = nwc
    }
    
    func onOpenURL(_ url: URL) async {
        guard url.scheme == "boostz" else { return }
        
        switch url.host() {
        default:
            break
        }
    }
}

struct AppStateViewModifier: ViewModifier {
    @Environment(\.nwc) private var nwc
    
    func body(content: Content) -> some View {
        content
            .environment(AppState(nwc: nwc))
    }
}

extension View {
    func setupAppState() -> some View {
        modifier(AppStateViewModifier())
    }
}
