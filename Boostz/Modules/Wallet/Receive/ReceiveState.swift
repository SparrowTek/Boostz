//
//  ReceiveState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/11/24.
//

import Foundation

@Observable
@MainActor
class ReceiveState {
    enum NavigationLink: Hashable {
        case createInvoice
//        case displayInvoice(CreatedInvoice)
    }
    
    private unowned let parentState: WalletState
    
    var path: [ReceiveState.NavigationLink] = []
    var lightningAddress: String {
//        guard let address = parentState.me?.lightningAddress else { return "" }
//        return "lightning:\(address)"
        ""
    }
    
    var lightningAddressMinusPrefix: String {
        ""
    }
    
    init(parentState: WalletState) {
        self.parentState = parentState
    }
    
    func doneTapped() {
        parentState.closeSheet()
        path = []
    }
}
