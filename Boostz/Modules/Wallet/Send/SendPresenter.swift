//
//  SendView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/10/24.
//

import SwiftUI
import AlbyKit

struct SendPresenter: View {
    @Environment(SendState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            SendView()
                .navigationDestination(for: SendState.NavigationLink.self) {
                    switch $0 {
                    case .sendLNURL(let address):
                        SendDetailsView(lightningAddress: address)
                    case .scanQR:
                        Text("SCAN QR")
                    }
                }
        }
    }
}

fileprivate struct SendView: View {
    @Environment(SendState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @Environment(AlbyKit.self) private var albyKit
    @State private var lightningInput = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("invoice, lightning address, or LNURL", text: $lightningInput)
                    .textFieldStyle(.roundedBorder)
                
                Button("go", action: continueWithInput)
                    .buttonStyle(.bordered)
            }
            .padding()
            
            // TODO: uncomment this code once we support scanning QR Codes with the camera
//            Text("OR:")
//                .font(.headline)
//            
//            Button("scan QR", systemImage: "qrcode.viewfinder", action: scanQR)
//                .font(.title)
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
        // TODO: we need a guard here
        // AlbyKit needs to check that the string is a valid invoice, lightning address, or LNURL
        // TODO: alert user if guard fails
//        guard let lightningAddress = try? albyKit.helpers.findLightningAddressInText(lightningInput) else { return }
        state.path.append(.sendLNURL(lightningInput))
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
                .environment(AlbyKit())
        }
}
