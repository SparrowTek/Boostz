//
//  SettingsState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation

@Observable
@MainActor
class SettingsState {
    enum NavigationLink: Hashable {
        case about
        case privacy
        case theme
    }
    
    private unowned let parentState: WalletState
    var path: [SettingsState.NavigationLink] = []
    var presentLogoutDialog = false
    
    init(parentState: WalletState) {
        self.parentState = parentState
    }
    
    func logout() {
        presentLogoutDialog = false
        parentState.logout()
    }
}
