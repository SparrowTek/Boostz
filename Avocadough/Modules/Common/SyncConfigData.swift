//
//  SyncConfigData.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 1/7/24.
//

import SwiftUI
import SwiftData
import NostrSDK

fileprivate struct SyncConfigData: ViewModifier {
    @Environment(AppState.self) private var state
    @Environment(\.nwc) private var nwc
    @Environment(\.modelContext) private var context
    @Query private var nwcCodes: [NWCConnection]
    @Query private var wallets: [Wallet]
//    @State private var dataSyncTrigger = false
    
    func body(content: Content) -> some View {
        content
//            .onChange(of: state.triggerDataSync, triggerDataSync)
            .task { await getWalletInfo() }
            .task { await getBTCPrice(content.isCanvas) }
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
            try saveWallet(info: info, balance: balance)
            state.configSuccessful()
        } catch {
            if wallets.count > 0 {
                state.configSuccessful()
            } else {
                state.logout(error: "Failed to connect to your wallet")
            }
        }
    }
    
    private func saveWallet(info: GetInfoResponse, balance: UInt64) throws {
        let wallet = Wallet(info: info, balance: balance)
        context.insert(wallet)
        try context.save()
    }
    
    private func getBTCPrice(_ isCanvas: Bool) async {
        let price = if isCanvas {
            BTCPrice(amount: "83939.07", lastUpdatedAtInUtcEpochSeconds: "1744395173", currency: "USD", version: "1", base: "BTC")
        } else {
            try? await BlockBTCPriceService().getCurrentPrice()
        }
        
        state.savePrice(price)
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
