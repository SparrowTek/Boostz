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
                    case .transactions:
                        TransactionsPresenter()
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
        background
            .overlay(
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
                        
                        if let accountBalance = state.accountBalance {
                            Text("\(accountBalance.balance) Sats")
                                .font(.title)
                        } else {
                            Text("NO INTERNET Sats")
                                .font(.title)
                                .redacted(reason: .placeholder)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button("send", action: sendSats)
                            Button("receive", action: receiveSats)
                        }
                        .buttonStyle(.boostz)
                        .padding()
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "slider.horizontal.3", action: openSettings)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "bolt.fill", action: showTransactions)
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
    
    private func showTransactions() {
        state.sheet = .transactions
    }
    
    private func openSettings() {
        state.sheet = .settings
    }
    
    private var background: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            Circle()
                .fill(.accent.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: -300)
            
            Circle()
                .fill(.accent.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: 50)
            
            Circle()
                .fill(.accent.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: -200)
            
            Circle()
                .fill(.accent.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: 100, y: 200)
        }
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
