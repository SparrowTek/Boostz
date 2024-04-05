//
//  SendDetailsView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/21/24.
//

import SwiftUI
import AlbyKit

@MainActor
struct SendDetailsView: View {
    @Environment(SendState.self) private var state
    var lightningAddress: String
    @State private var amount = ""
    @State private var requestInProgress = false
    @State private var confirmationTrigger = PlainTaskTrigger()
    @State private var bolt11Payment: Bolt11Payment?
    @State private var errorMessage: LocalizedStringResource?
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                Text("sending to:")
                    .font(.headline)
                Text(lightningAddress)
                    .font(.subheadline)
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("amount:")
                    .font(.headline)
                TextField("between 1 and 500,000 sats", text: $amount)
                    .font(.subheadline)
                    .textFieldStyle(.roundedBorder)
                Text(state.accountBalance)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            HStack {
                PresetSatVauleButton(value: "1K", action: { setAmount(1_000) } )
                PresetSatVauleButton(value: "5K", action: { setAmount(5_000) } )
                PresetSatVauleButton(value: "10K", action: { setAmount(10_000) } )
                PresetSatVauleButton(value: "25K", action: { setAmount(25_000) } )
            }
            .padding([.horizontal, .top])
            
            Spacer()
            
            HStack {
                Button("cancel", action: cancel)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.boostz)
                
                Button(action: triggerConfirmation) {
                    ZStack {
                        Text("confirm")
                            .opacity(requestInProgress ? 0 : 1)
                        ProgressView()
                            .opacity(requestInProgress ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.boostz)
            }
            .padding()
        }
        .navigationTitle("send")
        .alert($errorMessage)
        .onChange(of: bolt11Payment, bolt11PaymentChanged)
        .task($confirmationTrigger) { await confirm() }
    }
    
    private func bolt11PaymentChanged() {
        guard bolt11Payment != nil else { return }
        state.paymentSent()
    }
    
    private func setAmount(_ amount: Int) {
        self.amount = "\(amount)"
    }
    
    private func cancel() {
        state.cancel()
    }
    
    private func triggerConfirmation() {
        confirmationTrigger.trigger()
    }
    
    private func confirm() async {
        defer { requestInProgress = false }
        requestInProgress = true
        
        guard !amount.isEmpty else {
            errorMessage = "Sat amount can not be empty"
            return
        }
        
        guard let amountAsInt = Int(amount), amountAsInt >= 1, amountAsInt <= 5_000_000 else {
            errorMessage = "Sat amount must be a number between 1 and 5,000,000"
            return
        }
        
        // TODO: check if the balance supports the send amount
//        guard let balance = Int(state.accountBalance), amountAsInt <= balance else {
//            errorMessage = "Please select an amount less than or equal to your current Sat balance"
//            return
//        }
        
        do {
            let invoice = try await LightningAddressDetailsProxyService().requestInvoice(lightningAddress: lightningAddress, amount: amount, comment: nil)
            bolt11Payment = try await PaymentsService().bolt11Payment(uploadModel: Bolt11PaymentUploadModel(invoice: invoice.invoice.pr))
        } catch {
            errorMessage = "There was a problem sending your sats. Please try again later."
        }
    }
}

@MainActor
fileprivate struct PresetSatVauleButton: View {
    var value: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(value)
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color.yellow)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.boostz)
    }
}

#Preview {
    NavigationStack {
        SendDetailsView(lightningAddress: "SparrowTek@getalby.com")
            .environment(SendState(parentState: .init(parentState: .init())))
    }
}
