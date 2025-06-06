//
//  LogoutTracker.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 6/6/25.
//

import SwiftUI
import SwiftData

fileprivate struct LogoutTracker: ViewModifier {
    @Environment(AppState.self) private var state
    @Environment(\.nwc) private var nwc
    @Environment(\.modelContext) private var context
    @State private var logoutTrigger = PlainTaskTrigger()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerLogout, triggerLogout)
            .task($logoutTrigger, logout)
    }
    
    private func triggerLogout() {
        logoutTrigger.trigger()
    }
    
    private func logout() async {
        nwc.hasConnected = false
    }
}

extension View {
    func logoutTracker() -> some View {
        modifier(LogoutTracker())
    }
}

#Preview {
    Text("Logout Data")
        .logoutTracker()
        .environment(AppState())
        .environment(\.nwc, NWC())
}
