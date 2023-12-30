//
//  AppState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import Foundation

@Observable
public class AppState {
    enum Route: Int, Identifiable {
        case wallet
        case setup
        
        var id: Int { rawValue }
    }
    
    var route: Route = .setup
    
    @ObservationIgnored
    lazy var walletState = WalletState(parentState: self)
    @ObservationIgnored
    lazy var setuoState = SetupState(parentState: self)
}
