//
//  ContentView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI

struct AppPresenter: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack {
            ContentView()
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

struct ContentView: View {
    @Environment(AppState.self) private var state
    @State private var sats = 999_999_999
    
    var body: some View {
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
        .commonView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "slider.horizontal.3", action: openSettings)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "bolt.fill", action: showTransactions)
            }
        }
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

#Preview {
    AppPresenter()
        .environment(AppState())
}
