//
//  SendDetailsView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/21/24.
//

import SwiftUI
import AlbyKit

struct SendDetailsView: View {
    @Environment(SendState.self) private var state
    @Environment(AlbyKit.self) private var alby
    var lightningAddress: String
    @State private var amount = ""
    @State private var requestInProgress = false
    @State private var confirmationTrigger = PlainTaskTrigger()
    @State private var bolt11Payment: Bolt11Payment?
    @State private var keysendPayment: KeysendPayment?
    
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
                Text("balance: 1,504 sats")
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
        .onChange(of: bolt11Payment, bolt11PaymentChanged)
        .onChange(of: keysendPayment, keysendPaymentChanged)
        .task($confirmationTrigger) { await confirm() }
    }
    
    private func bolt11PaymentChanged() {
        guard bolt11Payment != nil else { return }
        paymentSent()
    }
    
    private func keysendPaymentChanged() {
        guard keysendPayment != nil else { return }
        paymentSent()
    }
    
    private func paymentSent() {
        // TODO: route to trasaction history and briefly highlight the new transaction
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
        
        // TODO: determine if bolt11 or keysend
        
        guard let amount = Int64(amount) else { return } // TODO: alert user to use number
        
//        keysendPayment = try? await alby.paymentsService.keysendPayment(uploadModel: KeysendPaymentUploadModel(amount: amount, destination: lightningAddress))
        
        bolt11Payment = try? await alby.paymentsService.bolt11Payment(uploadModel: Bolt11PaymentUploadModel(invoice: lightningAddress, amount: amount))
    }
}

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
            .environment(AlbyKit())
    }
}
