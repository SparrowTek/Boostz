//
//  WalletPresenter.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/29/23.
//

import SwiftUI
import SwiftData

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
                .alert($state.errorMessage)
        }
    }
}

struct WalletView: View {
    @Environment(\.reachability) private var reachability
    @Environment(WalletState.self) private var state
    @State private var requestInProgress = false
    @Query private var wallets: [Wallet]
    
    private var wallet: Wallet? {
        wallets.first
    }
    
    private var redacted: Bool {
        guard let wallet else { return true }
        return !wallet.methods.contains(where: { $0 == .getBalance } )
    }
    
    var body: some View {
        VStack {
            if reachability.connectionState != .good {
                NetworkNotReachable()
                    .transition(.move(edge: .top))
            }
            
            Text((wallets.first?.balance.millisatsToSats() ?? 0).currency)
                .font(.title)
                .redacted(reason: redacted ? .placeholder : .invalidated)
                .contentShape(Rectangle())
                .onTapGesture(perform: tappedBalance)
                .padding()
            
            HStack {
                Button("send", systemImage: "arrow.up.circle", action: sendSats)
                Button("receive", systemImage: "arrow.down.circle", action: receiveSats)
            }
            .buttonStyle(.avocadough)
            .padding()
            
            if let wallet, wallet.methods.contains(where: { $0 == .listTransactions }) {
                TransactionsView()
            } else {
                ContentUnavailableView("The currect NWC wallet connection does not have permission to see transaction data", systemImage: "lock.slash.fill")
            }
        }
        .fullScreenColorView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "slider.horizontal.3", action: openSettings)
            }
            
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Avocadough")
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
    
    private func tappedBalance() {
        guard redacted else { return }
        state.errorMessage = "The current NWC wallet connection does not have permission to see your balance"
    }
    
    private func sendSats() {
        if let wallet, wallet.methods.contains(where: { $0 == .payInvoice }) {
            state.sheet = .send
        } else {
            state.errorMessage = "The currect NWC wallet connection does not have permission to send sats"
        }
    }
    
    private func receiveSats() {
        if let wallet, wallet.methods.contains(where: { $0 == .makeInvoice }) {
            state.sheet = .receive
        } else {
            state.errorMessage = "The currect NWC wallet connection does not have permission to make an invoice"
        }
    }
    
    private func openSettings() {
        state.sheet = .settings
    }
}

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
#Preview(traits: .sampleComposite) {
    WalletPresenter()
        .environment(AppState())
        .environment(WalletState(parentState: .init()))
        .environment(\.reachability, Reachability())
}
#endif
