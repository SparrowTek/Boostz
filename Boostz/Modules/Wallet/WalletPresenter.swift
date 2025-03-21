//
//  WalletPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/29/23.
//

import SwiftUI
import SwiftData

@MainActor
struct WalletPresenter: View {
    @Environment(WalletState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack {
            WalletView()
                .sheet(item: $state.sheet) {
                    switch $0 {
                    case .settings:
                        SettingsPresenter()
                            .environment(state.settingsState)
                    case .send:
                        SendPresenter()
                            .environment(state.sendState)
                            .interactiveDismissDisabled()
                    case .receive:
                        ReceivePresenter()
                            .environment(state.receiveState)
                            .interactiveDismissDisabled()
                    case .open(let transaction):
                        TransactionDetailsView(transaction: transaction)
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.medium])
                    }
                }
        }
    }
}

@MainActor
struct WalletView: View {
    @Environment(\.reachability) private var reachability
    @Environment(WalletState.self) private var state
    @State private var requestInProgress = false
    @Query private var wallets: [Wallet]
    
    var body: some View {
        VStack {
            if reachability.connectionState != .good {
                NetworkNotReachable()
                    .transition(.move(edge: .top))
            }
            
            Text((wallets.first?.balance.millisatsToSats() ?? 0).currency)
                .font(.title)
                .redacted(reason: wallets.first != nil ? .invalidated : .placeholder)
                .padding()
            
            HStack {
                Button("send", systemImage: "arrow.up.circle", action: sendSats)
                Button("receive", systemImage: "arrow.down.circle", action: receiveSats)
            }
            .buttonStyle(.boostz)
            .padding()
            
            TransactionsView()
        }
        .fullScreenColorView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "slider.horizontal.3", action: openSettings)
            }
            
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Boostz")
                        .font(.largeTitle)
                        .bold()
                    
                    Image(systemName: "bolt.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color.yellow)
                    Image(systemName: "bolt.fill")
                        .imageScale(.large)
                        .foregroundStyle(Color.yellow)
                }
                .setForegroundStyle()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .syncTransactionData(requestInProgress: $requestInProgress)
        .task { await reachability.startMonitoring() }
    }
    
    private func sendSats() {
        state.sheet = .send
    }
    
    private func receiveSats() {
        state.sheet = .receive
    }
    
    private func openSettings() {
        state.sheet = .settings
    }
}

@MainActor
fileprivate struct NetworkNotReachable: View {
    var body: some View {
        ZStack {
            Color.red
                .frame(height: 44)
                .frame(maxWidth: .infinity)
            
            HStack {
                Image(systemName: "network.slash")
                Text("poor network connection")
            }
            .foregroundStyle(.white)
            .font(.headline)
        }
    }
}

#if DEBUG
#Preview(traits: .sampleWallet, .sampleTransactions) {
    WalletPresenter()
        .environment(AppState())
        .environment(WalletState(parentState: .init()))
        .environment(\.reachability, Reachability())
}
#endif
