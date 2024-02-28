//
//  ReceiveState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/11/24.
//

import Foundation

@Observable
class ReceiveState {
    enum NavigationLink: Hashable {
        case createInvoice
        case displayInvoice
    }
    
    private unowned let parentState: WalletState
    
    var path: [ReceiveState.NavigationLink] = []
    var lightningAddress: String {
        guard let address = parentState.me?.lightningAddress else { return "" }
        return "lightning:\(address)"
    }
    
    var lightningAddressMinusPrefix: String {
        parentState.me?.lightningAddress ?? ""
    }
    
    init(parentState: WalletState) {
        self.parentState = parentState
    }
    
    
    
}
