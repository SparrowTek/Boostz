//
//  SendState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/14/24.
//

import Foundation
import AlbyKit

@Observable
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
}
