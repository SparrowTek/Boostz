//
//  DisplayInvoiceView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/28/24.
//

import SwiftUI
import AlbyKit

struct DisplayInvoiceView: View {
    var invoice: CreatedInvoice
    @State private var invoiceCopied = false
    
    var body: some View {
        VStack {
            QRCodeImage(code: invoice.paymentRequest)
            Text("\(invoice.amount) SATS")
                .bold()
                .padding()
            
            Text("waiting for payment...")
            Button("check status", action: checkInvoiceStatus)
                .buttonStyle(.bordered)
            
            ZStack {
                Button(action: copyInvoice) {
                    HStack {
                        Text("copy invoice")
                        Image(systemName: "doc.on.doc")
                    }
                }
                .buttonStyle(.boostz)
                .opacity(invoiceCopied ? 0 : 1)
                
                Text("Copied!")
                    .foregroundStyle(Color.green)
                    .opacity(invoiceCopied ? 1 : 0)
            }
            .padding(.vertical)
        }
        .padding()
    }
    
    private func checkInvoiceStatus() {
        // TODO: implement checkInvoiceStatus
    }
    
    private func copyInvoice() {
        UIPasteboard.general.string = invoice.paymentRequest
        invoiceCopied = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            invoiceCopied = false
        }
    }
}

#Preview {
    DisplayInvoiceView(invoice: .init(amount: 4536, expiresAt: .now, paymentHash: "wwowow", paymentRequest: "lnbc555550n1pjal89dpp5alsdh4aewkpkmw7qf7jpv7g9ege6rac0na85g49403sa0naayjuqdp8fd2kgmtd248rwjmkd44yz6n5vaqnynt0x3jxwaccqzzsxqyz5vqsp5wug9d25x60l7ewslkmzuvlqvmq8mfvu8kzkhugyfuf9j34fmu4js9qyyssq4jyqjfhyyw9tt090w523rqjy08u9fqhry4ze34v8af3gvud6wy9h5nfayg0v8s2fynwtrsa0pcdzx582yssra97rt0kaqmu4uzp6zxgqjhlhlw"))
}
