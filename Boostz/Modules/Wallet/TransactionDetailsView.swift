//
//  TransactionDetailsView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 3/18/25.
//

import SwiftUI

struct TransactionDetailsView: View {
    var transaction: Transaction
    
    var body: some View {
        Text(transaction.paymentHash)
            .fullScreenColorView()
    }
}

//
//#if DEBUG
//#Preview {
////    @Previewable @State
//    Text("wow")
//}
//#endif
