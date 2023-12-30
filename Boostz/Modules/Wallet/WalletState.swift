//
//  WalletState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/30/23.
//

import Foundation

@Observable
class WalletState {
    enum Sheet: Int, Identifiable {
        case settings
        case transactions
        case send
        case receive
        
        var id: Int { rawValue }
    }
    
    var sheet: Sheet?
    
    private unowned let parentState: AppState
    
    @ObservationIgnored
    lazy var settingsState = SettingsState(parentState: self)
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}
