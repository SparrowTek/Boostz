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
        
        var id: Int { rawValue }
    }
    
    var sheet: Sheet?
}
