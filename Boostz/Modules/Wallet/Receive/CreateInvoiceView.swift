//
//  CreateInvoiceView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/23/24.
//

import SwiftUI

struct CreateInvoiceView: View {
    @Environment(ReceiveState.self) private var state
    @State private var amount = ""
    @State private var description = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("amount")
            TextField("Amount in Satoshi", text: $amount)
                .textFieldStyle(.roundedBorder)
            
            Text("description")
                .padding(.top)
            TextField("For e.g. who is sending this payment?", text: $amount)
                .textFieldStyle(.roundedBorder)
            
            Button("create invoice", action: createInvoice)
                .buttonStyle(.boostz)
                .padding(.top)
        }
        .padding(.horizontal)
    }
    
    private func createInvoice() {
        state.path.append(.displayInvoice)
    }
}

#Preview {
    CreateInvoiceView()
        .environment(ReceiveState(parentState: .init(parentState: .init())))
}
