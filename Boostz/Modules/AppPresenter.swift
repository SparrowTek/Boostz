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
                Text("Setup")
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
    AppPresenter()
        .environment(AppState())
}
