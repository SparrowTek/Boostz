//
//  TransactionsPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/9/24.
//

import SwiftUI
import AlbyKit

struct TransactionsPresenter: View {
    var body: some View {
        NavigationStack {
            TransactionsView()
        }
            
    }
}

struct TransactionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WalletState.self) private var state
    @Environment(AlbyKit.self) private var alby
    @State private var page = 1
    @State private var requestInProgress = false
    
    // TODO: implement pagination
    var body: some View {
        Group {
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
            }
        }
        .commonView()
        .navigationTitle("transactions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
        .task { await getInvoices() }
        .refreshable { await getInvoices() }
    }
    
    private func getInvoices() async {
        defer { requestInProgress = false }
        requestInProgress = true
        
        do {
            let invoiceHistory = try await alby.invoicesService.getAllInvoiceHistory(with: InvoiceHistoryUploadModel(page: page, items: 50))
            state.invoiceHistory = invoiceHistory
            
            for invoice in invoiceHistory {
                print(invoice)
            }
        } catch {
            print(error)
        }
    }
}

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
            TransactionsPresenter()
                .interactiveDismissDisabled()
                .environment(WalletState(parentState: .init()))
                .environment(AlbyKit())
        }
}
