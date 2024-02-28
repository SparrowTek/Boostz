//
//  CreateInvoiceView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/23/24.
//

import SwiftUI
import AlbyKit

struct CreateInvoiceView: View {
    @Environment(ReceiveState.self) private var state
    @Environment(AlbyKit.self) private var alby
    @State private var amount = ""
    @State private var description = ""
    @State private var createInvoiceTrigger = PlainTaskTrigger()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("amount")
            TextField("Amount in Satoshi", text: $amount)
                .textFieldStyle(.roundedBorder)
            
            Text("description")
                .padding(.top)
            TextField("For e.g. who is sending this payment?", text: $description)
                .textFieldStyle(.roundedBorder)
            
            Button("create invoice", action: triggerCreateInvoice)
                .buttonStyle(.boostz)
                .padding(.top)
        }
        .padding(.horizontal)
        .task($createInvoiceTrigger) { await createInvoice() }
    }
    
    private func triggerCreateInvoice() {
        createInvoiceTrigger.trigger()
    }
    
    private func createInvoice() async {
        guard let amount = Int64(amount) else { return } // TODO: alert user if this fails
        guard let invoice = try? await alby.invoicesService.create(invoice: InvoiceUploadModel(amount: amount, description: description)) else { return } // TODO: alert user of failed invoice creation
        state.path.append(.displayInvoice(invoice))
    }
}

#Preview {
    CreateInvoiceView()
        .environment(ReceiveState(parentState: .init(parentState: .init())))
        .environment(AlbyKit())
}
