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
        case sendLNURL(String)
        case scanQR
    }
    
    private unowned let parentState: WalletState
    var path: [SendState.NavigationLink] = []
    
    init(parentState: WalletState) {
        self.parentState = parentState
    }
    
    func cancel() {
        clearPathAndCloseSheet()
    }
    
    func paymentSent() {
        clearPathAndCloseSheet()
    }
    
    private func clearPathAndCloseSheet() {
        path = []
        parentState.sheet = nil
    }
}
