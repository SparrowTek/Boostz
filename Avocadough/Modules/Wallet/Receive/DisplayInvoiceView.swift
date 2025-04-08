//
//  DisplayInvoiceView.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 2/28/24.
//

import SwiftUI
import NostrSDK

struct DisplayInvoiceView: View {
    var invoice: MakeInvoiceResponse
    @State private var invoiceCopied = false
    @State private var checkInvoiceTrigger = PlainTaskTrigger()
//    @State private var invoiceResponse: Invoice?
    @Environment(ReceiveState.self) private var state
    @State private var requestInProgress = false
    
    private var isSettled: Bool {
//        invoiceResponse != nil && invoiceResponse?.state == .settled
        false
    }
    
    var body: some View {
        VStack {
            QRCodeImage(code: invoice.invoice)
//            Text("\(invoice.amount ?? 0) SATS")
//                .bold()
//                .padding()
            
            Text(isSettled ? "paid" : "waiting for payment...")
            Button(action: triggerCheckInvoiceStatus) {
                ZStack {
                    Text("check status")
                        .opacity(requestInProgress ? 0 : 1)
                    ProgressView()
                        .opacity(requestInProgress ? 1 : 0)
                }
            }
                .buttonStyle(.bordered)
                .disabled(isSettled)
                .opacity(isSettled ? 0 : 1)
            
            ZStack {
                Button(action: copyInvoice) {
                    HStack {
                        Text("copy invoice")
                        Image(systemName: "doc.on.doc")
                    }
                }
                .buttonStyle(.avocadough)
                .opacity(invoiceCopied ? 0 : 1)
                
                Text("copied!")
                    .foregroundStyle(Color.green)
                    .opacity(invoiceCopied ? 1 : 0)
            }
            .padding(.vertical)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: doneTapped)
            }
        }
        .task($checkInvoiceTrigger) { await checkInvoiceStatus() }
    }
    
    private func doneTapped() {
        state.doneTapped()
    }
    
    private func triggerCheckInvoiceStatus() {
        checkInvoiceTrigger.trigger()
    }
    
    private func checkInvoiceStatus() async {
        defer { requestInProgress = false }
        requestInProgress = true
//        guard let invoice = try? await InvoicesService().getInvoice(withHash: invoice.paymentHash ?? "") else { return }
//        invoiceResponse = invoice
    }
    
    private func copyInvoice() {
//        UIPasteboard.general.string = invoice.paymentRequest
//        invoiceCopied = true
//        
//        Task {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            invoiceCopied = false
//        }
    }
}

#Preview {
    DisplayInvoiceView(invoice: MakeInvoiceResponse(invoice: "mkewr34rt8ug", paymentHash: "fmjnds"))
        .environment(ReceiveState(parentState: .init(parentState: .init())))
}
