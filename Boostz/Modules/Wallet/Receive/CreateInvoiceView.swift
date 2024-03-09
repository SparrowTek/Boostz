//
//  CreateInvoiceView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/23/24.
//

import SwiftUI
import AlbyKit

@MainActor
struct CreateInvoiceView: View {
    @Environment(ReceiveState.self) private var state
    @Environment(AlbyKit.self) private var alby
    @State private var amount = ""
    @State private var description = ""
    @State private var createInvoiceTrigger = PlainTaskTrigger()
    @State private var requestInProgress = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("amount")
            TextField("amount in satoshi", text: $amount)
                .textFieldStyle(.roundedBorder)
            
            Text("description")
                .padding(.top)
            TextField("for e.g. who is sending this payment?", text: $description)
                .textFieldStyle(.roundedBorder)
            
            Button(action: triggerCreateInvoice) {
                ZStack {
                    Text("create invoice")
                        .opacity(requestInProgress ? 0 : 1)
                    ProgressView()
                        .opacity(requestInProgress ? 1 : 0)
                }
            }
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
        defer { requestInProgress = false }
        requestInProgress = true
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
