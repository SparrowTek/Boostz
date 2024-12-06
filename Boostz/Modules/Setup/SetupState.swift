//
//  SetupState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/6/24.
//

import Foundation

@Observable
@MainActor
class SetupState {
    private unowned let parentState: AppState
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}
