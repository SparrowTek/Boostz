//
//  SyncConfigData.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/7/24.
//

import SwiftUI
import AlbyKit

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
        print("### TRIGGER")
        guard state.triggerDataSync else { return }
        print("### past guard")
        state.triggerDataSync = false
        dataSyncTrigger.trigger()
    }
    
    private func getAccountInfo() async {
        print("### GET DATA")
        do {
            async let accountSummary = try alby.accountService.getAccountSummary()
            async let accountBalance = try alby.accountService.getAccountBalance()
            async let me = try alby.accountService.getPersonalInformation()
            state.setAccountSummary(try await accountSummary)
            state.setAccountBalance(try await accountBalance)
            state.setMe(try await me)
            state.route = .wallet
        } catch {
            print("### ERROR: \(error)")
            if case .statusCode(let code, _) = error as? NetworkError, code == .unauthorized {
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
