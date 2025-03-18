//
//  TransactionsView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/9/24.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WalletState.self) private var state
    @State private var page = 1
    @State private var requestInProgress = false
    @Query(sort: \Transaction.createdAt, order: .reverse) private var transactions: [Transaction]
    
    var body: some View {
        VStack {
            if transactions.isEmpty && requestInProgress {
                ProgressView()
            } else if transactions.isEmpty {
                ContentUnavailableView("there is no transaction history available", systemImage: "bolt.slash.fill")
            } else {
                List {
                    ForEach(transactions) { transaction in
                        TransactionCell(transaction: transaction)
                            .onAppear { checkIfAtBottomAndFetchMore(transaction) }
                    }
                    
                    if requestInProgress {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
        }
        .fullScreenColorView()
        .refreshable { await refresh() }
    }
    
    private func refresh() async {
        state.refresh()
    }
    
    private func checkIfAtBottomAndFetchMore(_ transaction: Transaction) {
        guard transactions.last == transaction else { return }
        state.getMoreTransactions()
    }
}


fileprivate struct TransactionCell: View {
    @Environment(WalletState.self) private var state
//    private let timer = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()
//    @State var startDate = Date.now
//    @State var timeElapsed: Int = 0
//    @State private var blink = false
    var transaction: Transaction
    
//    private var isTopCell: Bool {
//        state.invoiceHistory.first == invoice
//    }
    
    private var title: String {
        switch transaction.transactionType {
        case .incoming: "received"
        case .outgoing: "sent"
        case .none: transaction.transactionDescription ?? ""
        }
    }
    
    private var arrow: String {
        switch transaction.transactionType {
        case .incoming: "arrowshape.down.circle"
        case .outgoing: "arrowshape.up.circle"
        case .none: ""
        }
    }
    
    private var color: Color {
        switch transaction.transactionType {
        case .incoming: .green
        case .outgoing: .red
        case .none: .gray
        }
    }
    
    var body: some View {
        Button(action: openInvoice) {
            HStack {
                Image(systemName: arrow)
                    .foregroundStyle(color)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    
                    Text(transaction.createdAt?.invoiceFormat ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Text("\(transaction.transactionType == .incoming ? "+" : "-")\(transaction.amount.millisatsToSats().currency)")
                    .font(.title3)
                    .foregroundStyle(color)
            }
        }
        .listRowBackground(Color.clear)
    }
//        .onReceive(timer) { firedDate in
//            withAnimation(.linear(duration: 0.75)) {
//                timeElapsed = Int(firedDate.timeIntervalSince(startDate))
//                guard state.highlightTopTransaction, isTopCell, timeElapsed < 5 else {
//                    timer.upstream.connect().cancel()
//                    blink = false
//                    state.highlightTopTransaction = false
//                    return
//                }
//                
//                blink.toggle()
//            }
//        }
//        .listRowBackground(blink ? Color.yellow : Color.clear)
    
    
    
    private func openInvoice() {
        state.sheet = .open(transaction)
    }
}

#if DEBUG
#Preview(traits: .sampleTransactions) {
    TransactionsView()
        .environment(AppState())
        .environment(WalletState(parentState: .init()))
}
#endif
