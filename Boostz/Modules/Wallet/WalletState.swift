//
//  WalletState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/30/23.
//

import Foundation
import AlbyKit

@Observable
@MainActor
class WalletState {
    enum Sheet: Int, Identifiable {
        case settings
        case send
        case receive
        
        var id: Int { rawValue }
    }
    
    var sheet: Sheet?
    var accountSummary: AccountSummary?
    var accountBalance: AccountBalance?
    var me: PersonalInformation?
    var keysend: Keysend?
    var reachability = Reachability()
    var invoiceHistory: [Invoice] = []
    var triggerTransactionSync = false
    var highlightTopTransaction = false
    
    private unowned let parentState: AppState
    
    @ObservationIgnored
    lazy var settingsState = SettingsState(parentState: self)
    @ObservationIgnored
    lazy var sendState = SendState(parentState: self)
    @ObservationIgnored
    lazy var receiveState = ReceiveState(parentState: self)
    
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
    
    func logout() {
        sheet = nil
        parentState.logout()
    }
    
    func closeSheet() {
        sheet = nil
    }
    
    func paymentSent() {
        triggerTransactionSync = true
        triggerDataSync()
        highlightTopTransaction = true
    }
}

extension WalletState: ReachabilityDelegate {
    func triggerDataSync() {
        parentState.triggerDataSync = true
    }
}
