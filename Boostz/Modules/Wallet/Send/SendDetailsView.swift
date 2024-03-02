//
//  SendDetailsView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/21/24.
//

import SwiftUI

struct SendDetailsView: View {
    @Environment(SendState.self) private var state
    var lightningAddress: String
    @State private var amount = ""
    
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
                Button("confirm", action: confirm)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.boostz)
            }
            .padding()
        }
        .navigationTitle("send")
    }
    
    private func setAmount(_ amount: Int) {
        self.amount = "\(amount)"
    }
    
    private func cancel() {
        state.cancel()
    }
    
    private func confirm() {
        
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
    }
}
