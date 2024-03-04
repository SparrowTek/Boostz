//
//  WalletPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/29/23.
//

import SwiftUI
import AlbyKit

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
//                            .presentationDragIndicator(.visible)
                    }
                }
        }
    }
}

struct WalletView: View {
    @Environment(WalletState.self) private var state
    
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
                if let accountBalance = state.accountBalance {
                    Text("\(accountBalance.balance) Sats")
                        .font(.title)
                        .padding()
                } else {
                    Text("NO INTERNET Sats")
                        .font(.title)
                        .redacted(reason: .placeholder)
                        .padding()
                }
                
                HStack {
                    Button("send", systemImage: "arrow.up.circle", action: sendSats)
                    Button("receive", systemImage: "arrow.down.circle", action: receiveSats)
                }
                .buttonStyle(.boostz)
                .padding()
                
                TransactionsView()
            }
        }
        .commonView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "slider.horizontal.3", action: openSettings)
            }
        }
        .syncConfigData()
        .task { await state.reachability.startMonitoring() }
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
        .environment(AppState())
        .environment(WalletState(parentState: .init()))
        .environment(AlbyKit())
}
