//
//  SendConfirmationView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 3/23/24.
//

import SwiftUI
import LightningDevKit

@MainActor
struct SendConfirmationView: View {
    @Environment(SendState.self) private var state
    @Environment(\.nwc) private var nwc
    var invoice: String
//    @State private var bolt11Payment: Bolt11Payment?
    @State private var confirmationTrigger = PlainTaskTrigger()
    @State private var requestInProgress = false
    @State private var errorMessage: LocalizedStringResource?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Confirm invoice:")
                .bold()
                .padding(.horizontal)
            Text("\(Bolt11Invoice(invoice: invoice)?.amount ?? 0) sats")
                .bold()
                .padding([.horizontal, .bottom])
            
            Text(invoice)
                .padding(.horizontal)
            
            Button(action: triggerConfirmation) {
                ZStack {
                    Text("confirm")
                        .opacity(requestInProgress ? 0 : 1)
                    ProgressView()
                        .opacity(requestInProgress ? 1 : 0)
                }
            }
            .buttonStyle(.boostz)
            .padding()
        }
//        .onChange(of: bolt11Payment, bolt11PaymentChanged)
        .task($confirmationTrigger) { await confirm() }
        .alert($errorMessage)
    }
    
    private func triggerConfirmation() {
        confirmationTrigger.trigger()
    }
    
    private func confirm() async {
        defer { requestInProgress = false }
        requestInProgress = true
        
        let amount: UInt64? = Bolt11Invoice(invoice: invoice)?.amount
        
        do {
            let preImage = try await nwc.payInvoice(invoice, amount: amount)
            print("SUCCESS: \(preImage)")
        } catch {
            errorMessage = "There was a problem confirming your payment. Please try again later"
        }
    }
    
    private func bolt11PaymentChanged() {
//        guard bolt11Payment != nil else { return }
//        state.paymentSent()
    }
}

#Preview {
    SendConfirmationView(invoice: "lnbc20u1pn2hnhmpp5hf964hhc77lf4vjpltdnuma0fdl2pp2afagzueg8h2gv8x2ju5tqdpzw3jhxarfdenjqnzyfvsxjm3qgfhk7um50gcqzzsxqyz5vqsp5a8ayrhgzyhgce6y49m9z5ypvngslkkajjfz8dx3qeg94gtl6dg9q9qxpqysgq53s3ddmvy0x2lq3jm06lh9eul0w8mtmgpct09g68uuketgw2xvsyfwmm6qjj9t7hrtu8ul859c93ggaz69quj9ltpszt4022cca6znsq9v2lmp")
        .environment(SendState(parentState: .init(parentState: .init())))
}

struct Bolt11Invoice {
    var amount: UInt64?
    
    init?(invoice: String) {
        amount = getSatsFromInvoice(bolt11: invoice)
    }
    
    func getSatsFromInvoice(bolt11: String) -> UInt64? {
        guard let milliSats = LightningDevKit.Bolt11Invoice.fromStr(s: bolt11).getValue()?.amountMilliSatoshis() else { return nil }
        return milliSats / 1000
    }
}
