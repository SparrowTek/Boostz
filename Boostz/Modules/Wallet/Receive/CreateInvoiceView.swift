//
//  CreateInvoiceView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/23/24.
//

import SwiftUI

@MainActor
struct CreateInvoiceView: View {
    @Environment(ReceiveState.self) private var state
    @Environment(\.nwc) private var nwc
    @State private var amount = ""
    @State private var description = ""
    @State private var createInvoiceTrigger = PlainTaskTrigger()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("amount")
            TextField("amount in satoshi", text: $amount)
                .textFieldStyle(.roundedBorder)
            
            Text("description")
                .padding(.top)
            TextField("for e.g. who is sending this payment?", text: $description)
                .textFieldStyle(.roundedBorder)
            
            Button("create invoice", action: triggerCreateInvoice)
                .buttonStyle(.boostz)
                .padding(.top)
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: doneTapped)
            }
        }
        .task($createInvoiceTrigger) { await createInvoice() }
    }
    
    private func doneTapped() {
        state.doneTapped()
    }
    
    private func triggerCreateInvoice() {
        createInvoiceTrigger.trigger()
    }
    
    private func createInvoice() async {
        // TODO: alert user if guards fail
        guard let amount = UInt64(amount) else { return }
        let description: String? = description.isEmpty ? nil : description
        
        guard let invoice = try? await nwc.makeInvoice(amount: amount, description: description, descriptionHash: nil, expiry: nil) else { return }
        state.path.append(.displayInvoice(invoice))
    }
}

#Preview {
    CreateInvoiceView()
        .environment(ReceiveState(parentState: .init(parentState: .init())))
        .environment(\.nwc, NWC())
}
