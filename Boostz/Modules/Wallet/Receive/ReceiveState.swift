//
//  ReceiveState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/11/24.
//

import Foundation

@Observable
class ReceiveState {
    private unowned let parentState: WalletState
    
    var lightningAddress: String {
        parentState.me?.lightningAddress ?? ""
    }
    
    init(parentState: WalletState) {
        self.parentState = parentState
    }
    
    
    
}
