//
//  ContentView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI
import SwiftData

@MainActor
struct AppPresenter: View {
    @Environment(AppState.self) private var state
    @Environment(\.modelContext) private var modelContext
    @Environment(\.nwc) private var nwc
    @Query private var relayURLs: [RelayURL]
    
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
        .onAppear(perform: determineRoute)
//        .task { await setupNWC() }
    }
    
    private func determineRoute() {
        state.determineRoute()
    }
    
//    private func setupNWC() async {
//        do {
//            try seedRelayURLs()
//            try nwc.connectToRelays(with: relayURLs.map { $0.url } )
//        } catch {}
//    }
    
//    private func seedRelayURLs() throws {
//        guard relayURLs.isEmpty else { return }
////        let boostzRelay = RelayURL(url: "wss://relay.boostz.xyz/v1")
//        let albyRelay = RelayURL(url: "wss://relay.getalby.com/v1")
////        modelContext.insert(boostzRelay)
//        modelContext.insert(albyRelay)
//        try modelContext.save()
//    }
}

#Preview {
    AppPresenter()
        .setupModel()
        .environment(\.nwc, NWC())
        .environment(AppState())
        .environment(ScanQRCodeState(parentState: SetupState(parentState: .init())))
}
