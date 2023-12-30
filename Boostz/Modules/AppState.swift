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
    
    func onOpenURL(_ url: URL) async {
        print("### onOpenURL: \(url)")
        guard let infoDictionary = Bundle.main.infoDictionary,
              let urlScheme = infoDictionary["AppURLScheme"] as? String,
              url.scheme == urlScheme,
              url.pathComponents.count >= 2 else { return }
        
        switch url.pathComponents[1] {
        case "alby":
            break
        default:
            break
        }
    }
}
