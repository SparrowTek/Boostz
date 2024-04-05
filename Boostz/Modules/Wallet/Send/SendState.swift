//
//  SendState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/14/24.
//

import Foundation
import AlbyKit

@Observable
@MainActor
class SendState {
    enum NavigationLink: Hashable {
        case sendInvoice(String)
        case getLightningAddressDetails(String)
        case scanQR
    }
    
    private unowned let parentState: WalletState
    var path: [SendState.NavigationLink] = []
    var accountBalance = ""
    
    init(parentState: WalletState) {
        self.parentState = parentState
        self.accountBalance = setAccountBalance()
    }
    
    func cancel() {
        clearPathAndCloseSheet()
    }
    
    func paymentSent() {
        parentState.paymentSent()
        clearPathAndCloseSheet()
    }
    
    private func setAccountBalance() -> String {
        let balance = parentState.accountBalance?.balance ?? 0
        return "balance: \(balance) sats"
    }
    
    private func clearPathAndCloseSheet() {
        path = []
        parentState.sheet = nil
    }
}
