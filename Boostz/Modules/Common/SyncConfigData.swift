//
//  SyncConfigData.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/7/24.
//

import SwiftUI

@MainActor
fileprivate struct SyncConfigData: ViewModifier {
    @Environment(AppState.self) private var state
    @Environment(\.nwc) private var nwc
    @State private var dataSyncTrigger = false
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerDataSync, triggerDataSync)
            .task { getWalletInfo() }
            .onChange(of: dataSyncTrigger) { getWalletInfo() }
    }
    
    private func triggerDataSync() {
        guard state.triggerDataSync else { return }
        state.triggerDataSync = false
        dataSyncTrigger.toggle()
    }
    
    private func getWalletInfo() {
        do {
            try nwc.getWalletInfo()
        } catch {
            // TODO: handle error
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
