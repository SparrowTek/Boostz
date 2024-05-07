//
//  TransactionsPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/9/24.
//

import SwiftUI
import AlbyKit

//struct TransactionsPresenter: View {
//    var body: some View {
//        NavigationStack {
//            TransactionsView()
//        }
//            
//    }
//}

@MainActor
struct TransactionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WalletState.self) private var state
    @State private var page = 1
    @State private var requestInProgress = false
    
    // TODO: implement pagination
    var body: some View {
        VStack {
            if state.invoiceHistory.isEmpty && requestInProgress {
                ProgressView()
            } else if state.invoiceHistory.isEmpty {
                ContentUnavailableView("there is no transaction history available", systemImage: "bolt.slash.fill")
            } else {
                List {
                    ForEach(state.invoiceHistory) {
                        TransactionCell(invoice: $0)
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .syncTransactionData(requestInProgress: $requestInProgress)
        .refreshable { await refresh() }
    }
    
    private func refresh() async {
        state.triggerTransactionSync = true
        state.triggerDataSync()
    }
}

@MainActor
fileprivate struct TransactionCell: View {
    @Environment(WalletState.self) private var state
    private let timer = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()
    @State var startDate = Date.now
    @State var timeElapsed: Int = 0
    @State private var blink = false
    var invoice: Invoice
    
    private var isTopCell: Bool {
        state.invoiceHistory.first == invoice
    }
    
    private var title: String {
        if !invoice.isInoming {
            "sent"
        } else if let memo = invoice.memo {
            memo
        } else if let comment = invoice.comment, !comment.isEmpty {
            comment
        } else {
            "received"
        }
    }
    
    private var arrow: String {
        invoice.isInoming ? "arrowshape.down.circle" : "arrowshape.up.circle"
    }
    
    private var color: Color {
        invoice.isInoming ? .green : .red
    }
    
    private var currency: String {
        invoice.amount == 1 ? "sat" : "sats"
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
                    
                    Text(invoice.createdAt?.invoiceFormat ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Text("\(invoice.isInoming ? "+" : "-")\(invoice.amount ?? 0) \(currency)")
                    .font(.title3)
                    .foregroundStyle(color)
            }
        }
        .onReceive(timer) { firedDate in
            withAnimation(.linear(duration: 0.75)) {
                timeElapsed = Int(firedDate.timeIntervalSince(startDate))
                guard state.highlightTopTransaction, isTopCell, timeElapsed < 5 else {
                    timer.upstream.connect().cancel()
                    blink = false
                    state.highlightTopTransaction = false
                    return
                }
                
                blink.toggle()
            }
        }
        .listRowBackground(blink ? Color.yellow : Color.clear)
    }
    
    private func openInvoice() {
        print("OPEN")
    }
}

extension Invoice {
    var isInoming: Bool {
        type?.lowercased() == "incoming"
    }
}

extension Invoice: Identifiable {
    public var id: String {
        identifier ?? ""
    }
    
    
}

#Preview {
    Text("wallet")
        .sheet(isPresented: .constant(true)) {
            TransactionsView()
                .interactiveDismissDisabled()
                .setupAlbyKit()
                .environment(AppState())
                .environment(WalletState(parentState: .init()))
        }
}
