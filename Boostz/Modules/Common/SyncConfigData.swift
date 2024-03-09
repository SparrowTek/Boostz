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
    @Environment(AlbyKit.self) private var alby
    @State private var dataSyncTrigger = PlainTaskTrigger()
    
    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerDataSync, triggerDataSync)
            .task($dataSyncTrigger) { await getAccountInfo() }
    }
    
    private func triggerDataSync() {
        guard state.triggerDataSync else { return }
        state.triggerDataSync = false
//        dataSyncTrigger.trigger()
        
        // FIXME: the task modifier that takes an id parameter has a bug. Investigate more why it occurs here
        // this Task should not be here. we should be triggering the dataSyncTrigger instead
        Task {
            await getAccountInfo()
        }
    }
    
    private func getAccountInfo() async {
        do {
            async let accountSummary = try alby.accountService.getAccountSummary()
            async let accountBalance = try alby.accountService.getAccountBalance()
            async let me = try alby.accountService.getPersonalInformation()
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
