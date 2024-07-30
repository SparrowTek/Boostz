//
//  SendConfirmationView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 3/23/24.
//

import SwiftUI
import AlbyKit
//import BreezSDKLiquid
//import LightningDevKit

@MainActor
struct SendConfirmationView: View {
    @Environment(SendState.self) private var state
    var invoice: String
    @State private var bolt11Payment: Bolt11Payment?
    @State private var confirmationTrigger = PlainTaskTrigger()
    @State private var requestInProgress = false
    @State private var errorMessage: LocalizedStringResource?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Confirm invoice:")
                .bold()
                .padding()
            Text(invoice)
                .padding(.horizontal)
            Text("\(Bolt11Invoice(invoice: invoice)?.amount ?? 0) sats")
                .bold()
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
        .onChange(of: bolt11Payment, bolt11PaymentChanged)
        .task($confirmationTrigger) { await confirm() }
        .alert($errorMessage)
    }
    
    private func triggerConfirmation() {
        confirmationTrigger.trigger()
    }
    
    private func confirm() async {
        defer { requestInProgress = false }
        requestInProgress = true
        
        do {
            bolt11Payment = try await PaymentsService().bolt11Payment(uploadModel: Bolt11PaymentUploadModel(invoice: invoice))
        } catch {
            errorMessage = "There was a problem confirming your payment. Please try again later"
        }
    }
    
    private func bolt11PaymentChanged() {
        guard bolt11Payment != nil else { return }
        state.paymentSent()
    }
}

#Preview {
    SendConfirmationView(invoice: "lnbcdfdjfnr839ei13943ouhr432brn32onr31hniunf")
        .environment(SendState(parentState: .init(parentState: .init())))
}

struct Bolt11Invoice {
    var amount: UInt64?
    
    init?(invoice: String) {
        amount = getSatsFromInvoice(bolt11: invoice)
    }
    
    func getSatsFromInvoice(bolt11: String) -> UInt64? {
//        do {
//            let parsedInvoice = try BreezSDKLiquid.parseInvoice(input: bolt11)
//            
//            // Extract the amount in satoshis
//            if let amountMsat = parsedInvoice.amountMsat {
//                let sats = amountMsat / 1000
//                return sats
//            } else {
//                print("Invoice does not contain amount information")
//                return nil
//            }
//        } catch {
//            print("Failed to parse invoice: \(error)")
//            return nil
//        }
        return nil
    }
}
