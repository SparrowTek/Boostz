//
//  SendDetailsView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/21/24.
//

import SwiftUI

struct SendDetailsView: View {
    var lightningAddress: String
    @State private var amount = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                Text("Sending to:")
                    .font(.headline)
                Text(lightningAddress)
                    .font(.subheadline)
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Amount:")
                    .font(.headline)
                TextField("between 1 and 500,000 sats", text: $amount)
                    .font(.subheadline)
                    .textFieldStyle(.roundedBorder)
                Text("balance: 1,504 sats")
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            HStack {
                PresetSatVauleButton(value: "1K", action: {})
                PresetSatVauleButton(value: "5K", action: {})
                PresetSatVauleButton(value: "10K", action: {})
                PresetSatVauleButton(value: "25K", action: {})
            }
            .padding([.horizontal, .top])
            
            
            HStack {
                Button("Cancel", action: {})
                    .frame(maxWidth: .infinity)
                Button("Confirm", action: {})
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("Send")
    }
}

fileprivate struct PresetSatVauleButton: View {
    var value: String
    var action: () -> Void
    
    var body: some View {
        Button(value, systemImage: "line.3.horizontal", action: action)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SendDetailsView(lightningAddress: "SparrowTek@getalby.com")
    }
}
