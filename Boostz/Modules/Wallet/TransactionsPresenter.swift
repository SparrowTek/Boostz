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
        .task { await getInvoices() }
        .refreshable { await getInvoices() }
    }
    
    private func getInvoices() async {
        defer { requestInProgress = false }
        requestInProgress = true
        guard let invoiceHistory = try? await InvoicesService().getAllInvoiceHistory(with: InvoiceHistoryUploadModel(page: page, items: 50)) else { return }
        state.invoiceHistory = invoiceHistory
    }
}

@MainActor
fileprivate struct TransactionCell: View {
    @Environment(WalletState.self) private var state
    var invoice: Invoice
    
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
                    
                    Text(invoice.createdAt.invoiceFormat)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Text("\(invoice.isInoming ? "+" : "-")\(invoice.amount) \(currency)")
                    .font(.title3)
                    .foregroundStyle(color)
            }
        }
        .listRowBackground(Color.clear)
    }
    
    private func openInvoice() {
        print("OPEN")
    }
}

extension Invoice {
    var isInoming: Bool {
        type.lowercased() == "incoming"
    }
}

extension Invoice: Identifiable {
    public var id: String {
        identifier
    }
    
    
}

#Preview {
    Text("wallet")
        .sheet(isPresented: .constant(true)) {
            TransactionsView()
                .interactiveDismissDisabled()
                .environment(WalletState(parentState: .init()))
        }
}
