//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation

@Observable
public class AppState {
    enum Sheet: Int, Identifiable {
        case settings
        case transactions
        case send
        case receive
        
        var id: Int { rawValue }
    }
    
    var sheet: Sheet?
}
