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
    
    enum Sheet: Int, Identifiable {
        case scanQR
        
        var id: Int { rawValue }
    }
    
    var sheet: Sheet?
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}
