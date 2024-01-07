//
//  WalletPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/29/23.
//

import SwiftUI

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
                    case .transactions:
                        Text("TRANSACTIONS")
                            .presentationDragIndicator(.visible)
                    case .send:
                        Text("SEND")
                            .presentationDragIndicator(.visible)
                    case .receive:
                        Text("RECEIVE")
                            .presentationDragIndicator(.visible)
                    }
                }
        }
    }
}

struct WalletView: View {
    @Environment(WalletState.self) private var state
    @State private var sats = 999_999_999
    
    var body: some View {
        ZStack {
            if state.reachability.connectionState != .good {
                VStack {
                    NetworkNotReachable()
                    Spacer()
                }
                .transition(.move(edge: .top))
            }
            
            VStack {
                Spacer()
                
                Text("\(sats) Sats")
                    .font(.title)
                
                Spacer()
                
                HStack {
                    Button("Send", action: sendSats)
                    Button("Receive", action: receiveSats)
                }
                .buttonStyle(.boostz)
                .padding()
            }
        }
        .commonView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "slider.horizontal.3", action: openSettings)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "bolt.fill", action: showTransactions)
            }
        }
        .task { await state.reachability.startMonitoring() }
    }
    
    private func sendSats() {
        state.sheet = .send
    }
    
    private func receiveSats() {
        state.sheet = .receive
    }
    
    private func showTransactions() {
        state.sheet = .transactions
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

#Preview {
    WalletPresenter()
        .environment(WalletState(parentState: .init()))
}
