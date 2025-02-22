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
    @Query private var nwcCodes: [NWCCode]
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
            let info = try await nwc.getInfo()
            let balance = try await nwc.getBalance()
            let transactions = try await nwc.listTransactions(from: Timestamp.fromSecs(secs: 1693876973), until: .now(), limit: 10, offset: 0, unpaid: nil, transactionType: .incoming)
            print("INFO: \(info)")
            print("BALANCE: \(balance)")
            print("TRANSACTIONS: \(transactions)")
            state.configSuccessful()
        } catch {
            // TODO: handle error
            print("ERROR listing transactions: \(error.localizedDescription)")
        }
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
