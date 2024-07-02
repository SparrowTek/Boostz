//
//  ReceivePresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/11/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ReceivePresenter: View {
    @Environment(ReceiveState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            ReceiveView()
                .navigationDestination(for: ReceiveState.NavigationLink.self) {
                    switch $0 {
                    case .createInvoice:
                        CreateInvoiceView()
                            .interactiveDismissDisabled()
                    case .displayInvoice(let invoice):
                        DisplayInvoiceView(invoice: invoice)
                    }
                }
        }
    }
}

fileprivate struct ReceiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ReceiveState.self) private var state
    @State private var lightningAddressCopied = false
    
    private var lightningAddress: String {
        #if DEBUG
        "lightning:sparrowtek@getalby.com"
        #else
        state.lightningAddress ?? ""
        #endif
    }
    
    private var lightningAddressMinusPrefix: String {
        #if DEBUG
        "sparrowtek@getalby.com"
        #else
        state.lightningAddressMinusPrefix
        #endif
    }
    
    var body: some View {
        VStack {
            QRCodeImage(code: lightningAddress)
                .frame(width: 200, height: 200)
                .padding()
            
            ZStack {
                Button(action: copyLightningAddress) {
                    HStack {
                        Text(lightningAddressMinusPrefix)
                        Image(systemName: "doc.on.doc")
                    }
                }
                .opacity(lightningAddressCopied ? 0 : 1)
                
                Text("copied!")
                    .foregroundStyle(Color.green)
                    .opacity(lightningAddressCopied ? 1 : 0)
            }
            .padding()
            
            Button(action: createLightningInvoice) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.yellow)
                            .frame(width: 50)
                            .padding(.vertical, 4)
                        Image(systemName: "bolt")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("lightning invoice")
                            .font(.headline)
                        Text("request instant and specific amount payment")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            .buttonStyle(.boostz)
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    private func createLightningInvoice() {
        state.path.append(.createInvoice)
    }
    
    private func copyLightningAddress() {
        UIPasteboard.general.string = lightningAddress
        lightningAddressCopied = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            lightningAddressCopied = false
        }
    }
}

#Preview {
    ReceivePresenter()
        .environment(ReceiveState(parentState: .init(parentState: .init())))
}
