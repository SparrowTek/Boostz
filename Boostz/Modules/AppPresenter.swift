//
//  ContentView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI

@MainActor
struct AppPresenter: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        Group {
            switch state.route {
            case .setup:
                SetupPresenter()
                    .environment(state.setupState)
            case .config:
                ConfigView()
            case .wallet:
                WalletPresenter()
                    .environment(state.walletState)
            }
        }
        .onOpenURL()
    }
}

#Preview {
    @Previewable @Environment(\.nwc) var nwc
    AppPresenter()
        .environment(AppState(nwc: nwc))
        .environment(ScanQRCodeState(parentState: SetupState(parentState: .init(nwc: nwc), nwc: nwc)))
}
