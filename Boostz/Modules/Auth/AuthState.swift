//
//  AuthState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/30/23.
//

import Foundation
import AlbyKit

@Observable
class AuthState {
    enum Sheet: Identifiable {
        case auth(SafariView)
        
        var id: Int {
            switch self {
            case .auth(_): 0
            }
        }
    }
    
    private unowned let parentState: AppState
    var sheet: Sheet?
    var albyCode: String?
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
    
    func dismissSheet() {
        sheet = nil
    }
    
    func saveAlbyToken(_ token: Token) {
        parentState.saveAlbyToken(token)
    }
    
    // TODO: temp method
    func goToConfig() {
        parentState.goToConfig()
    }
}
