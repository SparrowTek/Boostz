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
        case unsupported
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
        do {
            switch try findLightningAddressInText(lightningInput) {
            case .bolt11Invoice(let invoice): state.path.append(.sendInvoice(invoice))
            case .bolt11LookupRequired(let lightningAddress): state.path.append(.getLightningAddressDetails(lightningAddress))
            }
        } catch LightningAddressError.unsupported {
            errorMessage = "This address format is currently unsupported"
        } catch {
            badLightningAddress()
        }
    }
    
    private func badLightningAddress() {
        errorMessage = "The address you entered is not valid. Please try again."
    }
    
    public func findLightningAddressInText(_ text: String) throws -> LightningAddressType {
        let text = text.lowercased()
        
        // Define the regex patterns
        let lightningPattern = #"(?i)((⚡|⚡️):?|lightning:?|lnurl:?)\s?(\S+)"#
        let albyUserPattern = #"^(https?:\/\/)?(www\.)?(\w+)@getalby\.com$"#
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        if let _ = try? text.firstMatch(of: Regex(lightningPattern)) {
//            return try getBolt11Lookup(for: text)
            throw LightningAddressError.unsupported
        }
        
        if let _ = try? text.firstMatch(of: Regex(emailRegEx)) {
            return .bolt11LookupRequired(text)
        }
        
        if let _ = try? text.firstMatch(of: Regex(albyUserPattern)) {
//            return try getBolt11Lookup(for: text)
            throw LightningAddressError.unsupported
        }
        
        return .bolt11Invoice(text)
    }
    
    private func getBolt11Lookup(for text: String) throws -> LightningAddressType {
        let text = text.lowercased()
        
        if text.hasPrefix("lnurl") ||
            text.hasPrefix("lightning") ||
            text.hasPrefix("⚡") {
            let components = text.components(separatedBy: ":")
            
            if components.count > 1 {
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
//                text.removePrefix("lnurl")
//                text.removePrefix("lightning")
//                text.removePrefix("⚡")
                return .bolt11LookupRequired(text)
            }
        }
        
        return .bolt11LookupRequired(text)
    }
    
    private func scanQR() {
        print("SCAN")
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
                .environment(SendState(parentState: .init(parentState: .init())))
                .environment(AlbyKit())
        }
}
