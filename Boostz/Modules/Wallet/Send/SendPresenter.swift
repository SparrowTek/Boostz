//
//  SendView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/10/24.
//

import SwiftUI
import AlbyKit

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
                        Text("SCAN QR")
                    }
                }
        }
    }
}

@MainActor
fileprivate struct SendView: View {
    enum LightningAddressError: Error {
        case badLightningAddress
    }
    
    enum LightningAddressType: Sendable {
        case bolt11Invoice(String)
        case bolt11LookupRequired(String)
    }
    
    @Environment(SendState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @Environment(AlbyKit.self) private var albyKit
    @State private var lightningInput = ""
    @State private var errorMessage: LocalizedStringResource?
    
    var body: some View {
        VStack {
            HStack {
                TextField("invoice, lightning address, or LNURL", text: $lightningInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
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
        .alert($errorMessage)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    private func continueWithInput() {
        switch try? findLightningAddressInText(lightningInput) {
        case .bolt11Invoice(let invoice): state.path.append(.sendInvoice(invoice))
        case .bolt11LookupRequired(let lightningAddress): state.path.append(.getLightningAddressDetails(lightningAddress))
        case .none: badLightningAddress()
        }
    }
    
    private func badLightningAddress() {
        errorMessage = "The address you entered is not valid. Please try again."
    }
    
    private func findLightningAddressInText(_ text: String) throws -> LightningAddressType {
        var text = text.lowercased()
        
        if text.hasPrefix("lnurl") ||
            text.hasPrefix("lightning") ||
            text.hasPrefix("⚡") {
            let components = text.components(separatedBy: ":")
            guard components.count > 1 else { throw LightningAddressError.badLightningAddress }
            
            var lookup = ""
            
            for component in components {
                guard component != components[0] else { continue }
                
                if component == components[1] {
                    lookup = component
                } else {
                    lookup = "\(lookup):\(component)"
                }
            }
            
            guard !lookup.isEmpty else { throw LightningAddressError.badLightningAddress }
            
            return .bolt11LookupRequired(lookup)
        } else {
            return .bolt11Invoice(text)
        }
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
