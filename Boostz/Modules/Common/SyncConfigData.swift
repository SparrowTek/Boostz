//
//  SyncConfigData.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/7/24.
//

import SwiftUI
import SwiftData
import NostrSDK

@MainActor
fileprivate struct SyncConfigData: ViewModifier {
    @Environment(AppState.self) private var state
    @Environment(\.nwc) private var nwc
    @Environment(\.modelContext) private var context
    @Query private var nwcCodes: [NWCConnection]
//    @State private var dataSyncTrigger = false
    
    func body(content: Content) -> some View {
        content
//            .onChange(of: state.triggerDataSync, triggerDataSync)
            .task { await getWalletInfo() }
//            .onChange(of: dataSyncTrigger) { await getWalletInfo() }
//            .task(id: dataSyncTrigger) { await getWalletInfo() }
    }
    
//    private func triggerDataSync() {
//        guard state.triggerDataSync else { return }
//        state.triggerDataSync = false
//        dataSyncTrigger.toggle()
//    }
    
    private func getWalletInfo() async {
        do {
            if let nwcCode = nwcCodes.first {
                try nwc.initializeNWCClient(pubKey: nwcCode.pubKey, relay: nwcCode.relay, lud16: nwcCode.lud16)
            } else {
                state.logout()
                return
            }
        } catch {
            if let nwcCode = nwcCodes.first {
                context.delete(nwcCode)
                try? context.save()
            }
            
            state.logout()
            return
        }
        
        do {
            let info = try await nwc.getInfo()
            let balance = try await nwc.getBalance()
            let transactions = try await nwc.listTransactions(from: nil, until: nil, limit: 10, offset: 0, unpaid: nil, transactionType: .incoming)
            try saveWallet(info: info, balance: balance)
            try saveTransactions(transactions)
            state.configSuccessful()
        } catch {
            // TODO: handle error
            print("ERROR listing transactions: \(error.localizedDescription)")
        }
    }
    
    private func saveWallet(info: GetInfoResponse, balance: UInt64) throws {
        let wallet = Wallet(info: info, balance: balance)
        context.insert(wallet)
        try context.save()
    }
    
    private func saveTransactions(_ lookupInvoiceResponses: [LookupInvoiceResponse]) throws {
        for lookupInvoiceResponse in lookupInvoiceResponses {
            let transaction = Transaction(lookupInvoiceResponse: lookupInvoiceResponse)
            context.insert(transaction)
        }
        
        try context.save()
    }
}

extension View {
    func syncConfigData() -> some View {
        modifier(SyncConfigData())
    }
}

#Preview {
    Text("Sync Config Data")
        .syncConfigData()
        .environment(AppState())
        .environment(\.nwc, NWC())
}
