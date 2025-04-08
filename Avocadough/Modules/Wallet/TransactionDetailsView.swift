//
//  TransactionDetailsView.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 3/18/25.
//

import SwiftUI
import SwiftData

struct TransactionDetailsView: View {
    var transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading) {
            Label(transaction.transactionType?.title ?? "", systemImage: transaction.transactionType?.arrow ?? "")
                .foregroundStyle(transaction.transactionType?.color ?? .gray)
                .font(.title)
                .bold()
                .padding(.bottom)
            
            Text("\(transaction.transactionType?.plusOrMinus ?? "")\(transaction.amount.millisatsToSats().currency)")
                .font(.title)
            
            ScrollView(showsIndicators: false) {
                TransactionDetailSection(title: "payment hash", value: transaction.paymentHash)
                
                if transaction.feesPaid > 0 {
                    TransactionDetailSection(title: "fees paid", value: transaction.feesPaid.currency)
                }
                
                if let settledAt = transaction.settledAt {
                    TransactionDetailSection(title: "settled at", value: settledAt.invoiceFormat)
                }
                
                if let preimage = transaction.preimage {
                    TransactionDetailSection(title: "preimage", value: preimage)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .fullScreenColorView()
    }
}

fileprivate struct TransactionDetailSection: View {
    let title: LocalizedStringKey
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            HStack(spacing: 0) {
                Text(title)
                Text(":")
                Spacer()
            }
            .frame(width: 150)
            
            Text(value)
            
            Spacer()
        }
        .padding(.top)
    }
}

#if DEBUG
#Preview(traits: .sampleTransactions) {
    @Previewable @Query var transactions: [Transaction]
    
    TransactionsView()
        .environment(AppState())
        .environment(WalletState(parentState: .init()))
        .sheet(isPresented: .constant(true)) {
            TransactionDetailsView(transaction: transactions.first!)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        }
}
#endif
