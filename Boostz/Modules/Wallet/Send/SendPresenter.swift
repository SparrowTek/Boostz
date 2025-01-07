//
//  SendView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/10/24.
//

import SwiftUI

@MainActor
struct SendPresenter: View {
    @Environment(SendState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            SendView()
                .navigationDestination(for: SendState.NavigationLink.self) {
                    switch $0 {
                    case .getLightningAddressDetails(let address):
                        SendDetailsView(lightningAddress: address)
                    case .sendInvoice(let invoice):
                        SendConfirmationView(invoice: invoice)
                    case .scanQR:
                        ScanQRCodeView()
                            .environment(state.scanQRCodeState)
                    }
                }
        }
    }
}

@MainActor
fileprivate struct SendView: View {
    @Environment(SendState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var lightningInput = ""
    
    var body: some View {
        @Bindable var state = state
        
        VStack {
            HStack {
                TextField("invoice, lightning address, or LNURL", text: $lightningInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                Button("go", action: continueWithInput)
                    .buttonStyle(.bordered)
            }
            .padding()
            
            Text("OR:")
                .font(.headline)
            
            Button("scan QR", systemImage: "qrcode.viewfinder", action: scanQR)
                .font(.title)
        }
        .fullScreenColorView()
        .navigationTitle("send BTC")
        .alert($state.errorMessage)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    private func continueWithInput() {
        state.continueWithInput(lightningInput)
    }
    
    private func scanQR() {
        state.path.append(.scanQR)
    }
}

// TODO: move this to a new file
extension String {
    mutating func removePrefix(_ prefix: String) {
        if self.hasPrefix(prefix) {
            self = String(self.dropFirst(prefix.count))
        }
    }
}

#Preview {
    Text("wallet")
        .sheet(isPresented: .constant(true)) {
            SendPresenter()
                .environment(AppState())
                .environment(SendState(parentState: .init(parentState: .init())))
        }
}
