//
//  SyncTransactionData.swift
//  Boostz
//
//  Created by Thomas Rademaker on 4/4/24.
//

import SwiftUI
import AlbyKit

@MainActor
fileprivate struct SyncTransactionData: ViewModifier {
    @Environment(WalletState.self) private var state
    @State private var transactionSyncTrigger = PlainTaskTrigger()
    @Binding var requestInProgress: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerTransactionSync, triggerTransactionSync)
            .task { await getTransactionData() }
            .task($transactionSyncTrigger) { await getTransactionData() }
    }
    
    private func triggerTransactionSync() {
        guard state.triggerTransactionSync else { return }
        state.triggerTransactionSync = false
        transactionSyncTrigger.trigger()
    }
    
    private func getTransactionData() async {
        defer { requestInProgress = false }
        requestInProgress = true
        
        // TODO: need to support pagination
        guard let invoiceHistory = try? await InvoicesService().getAllInvoiceHistory(with: InvoiceHistoryUploadModel(page: 1, items: 50)) else { return }
        state.invoiceHistory = invoiceHistory
    }
}

extension View {
    func syncTransactionData(requestInProgress: Binding<Bool>) -> some View {
        modifier(SyncTransactionData(requestInProgress: requestInProgress))
    }
}
