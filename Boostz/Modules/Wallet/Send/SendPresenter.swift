//
//  SendView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/10/24.
//

import SwiftUI

struct SendPresenter: View {
    @Environment(SendState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            SendView()
                .navigationDestination(for: SendState.NavigationLink.self) {
                    switch $0 {
                    case .sendLNURL:
                        Text("SEND LNURL")
                    }
                }
        }
    }
}

fileprivate struct SendView: View {
    @Environment(SendState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var lightningInput = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Invoice, lightning address, or LNURL", text: $lightningInput)
                    .textFieldStyle(.roundedBorder)
                
                Button("go", action: continueWithInput)
                    .buttonStyle(.bordered)
            }
            .padding()
            
            Text("OR:")
                .font(.headline)
            
            Button("Scan QR", systemImage: "qrcode.viewfinder", action: scanQR)
                .font(.title)
        }
        .commonView()
        .navigationTitle("send BTC")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    private func continueWithInput() {
        state.path.append(.sendLNURL)
    }
    
    private func scanQR() {
        print("SCAN")
    }
}

#Preview {
    Text("wallet")
        .sheet(isPresented: .constant(true)) {
            SendPresenter()
                .environment(SendState(parentState: .init(parentState: .init())))
        }
}
