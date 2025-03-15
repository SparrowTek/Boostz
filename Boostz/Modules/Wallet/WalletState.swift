//
//  WalletState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/30/23.
//

import Foundation

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
    var triggerTransactionSync = false
    var highlightTopTransaction = false
    var transactionDataSyncPage = 1
    
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
    
    func closeSheet() {
        sheet = nil
    }
    
    func paymentSent() {
        triggerTransactionSync = true
        triggerDataSync()
        highlightTopTransaction = true
    }
    
    func disconnectNWC() {
        parentState.logout()
    }
}

extension WalletState: ReachabilityDelegate {
    func triggerDataSync() {
        parentState.triggerDataSync = true
    }
}
