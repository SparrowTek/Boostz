//
//  SyncConfigData.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/7/24.
//

import SwiftUI
import AlbyKit

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
        do {
            let accountsService = await AccountsService()
            async let accountSummary = try accountsService.getAccountSummary()
            async let accountBalance = try accountsService.getAccountBalance()
            async let me = try accountsService.getPersonalInformation()
            state.setAccountSummary(try await accountSummary)
            state.setAccountBalance(try await accountBalance)
            state.setMe(try await me)
            state.route = .wallet
        } catch {
            if case .network(let networkError) = error as? AlbyError, case .statusCode(let code, _) = networkError, code == StatusCode.unauthorized {
                state.logout()
            } else {
                state.route = .wallet
            }
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
        .setupAlbyKit()
        .syncConfigData()
        .environment(AppState())
}
