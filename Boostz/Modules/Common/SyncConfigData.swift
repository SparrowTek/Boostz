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
    @State private var dataSyncTrigger = PlainTaskTrigger()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerDataSync, triggerDataSync)
            .task { await getAccountInfo() }
            .task($dataSyncTrigger) { await getAccountInfo() }
    }
    
    private func triggerDataSync() {
        guard state.triggerDataSync else { return }
        state.triggerDataSync = false
        dataSyncTrigger.trigger()
    }
    
    private func getAccountInfo() async {
        // TODO: get wallet info
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
        .setupAppState()
}
