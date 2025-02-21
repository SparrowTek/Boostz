//
//  SyncConfigData.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/7/24.
//

import SwiftUI
import SwiftData

@MainActor
fileprivate struct SyncConfigData: ViewModifier {
    @Environment(AppState.self) private var state
    @Environment(\.nwc) private var nwc
    @Query private var nwcCodes: [NWCCode]
    @State private var dataSyncTrigger = false
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerDataSync, triggerDataSync)
            .task { getWalletInfo() }
            .onChange(of: dataSyncTrigger) { getWalletInfo() }
            .onChange(of: nwc.currentRelayResponse) { evaluateNWCResponse() }
    }
    
    private func triggerDataSync() {
        guard state.triggerDataSync else { return }
        state.triggerDataSync = false
        dataSyncTrigger.toggle()
    }
    
    private func getWalletInfo() {
        guard let nwcCode = nwcCodes.first else { return }
        do {
//            try nwc.getWalletInfo()
//            try nwc.listTransactions(pubKey: nwcCode.pubKey)
            try nwc.getBalance(pubKey: nwcCode.pubKey)
        } catch {
            // TODO: handle error
            print("ERROR listing transactions: \(error.localizedDescription)")
        }
    }
    
    private func evaluateNWCResponse() {
        #warning("This logic needs to be gated somehow for only certain types.. oh maybe by using the eventID?")
//        print("currentPublishedEvent: \(String(describing: nwc.currentPublishedEvent?.kind))")
//        guard nwc.currentPublishedEvent is WalletConnectInfoEvent else { return }
        switch nwc.currentRelayResponse {
        case .ok(let eventId, let success, let message):
            break
//            print("eventId: \(eventId)")
//            print("success: \(success)")
//            print("message: \(message)")
            
            // TODO: maybe log eventId and message?
//            if success {
//                // TODO: something!!
//                state.configSuccessful()
//            } else {
//                // TODO: handle error
//            }
        default: break
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
