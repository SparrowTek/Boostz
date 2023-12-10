//
//  SettingsState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation

@Observable
class SettingsState {
    enum NavigationLink: Hashable {
        case about
        case privacy
        case albyInfo
        case theme
    }
    
    private unowned let parentState: AppState
    var path: [SettingsState.NavigationLink] = []
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}
