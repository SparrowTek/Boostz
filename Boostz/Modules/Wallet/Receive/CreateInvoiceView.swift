//
//  CreateInvoiceView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/23/24.
//

import SwiftUI

struct CreateInvoiceView: View {
    @State private var amount = 0
    @State private var description = ""
    
    var body: some View {
        VStack {
            Text("amount")
            Text("description")
        }
    }
}

#Preview {
    CreateInvoiceView()
}
