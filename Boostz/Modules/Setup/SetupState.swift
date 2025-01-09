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
    var foundQRCode: String?
    @ObservationIgnored
    lazy var scanQRCodeState = ScanQRCodeState(parentState: self)
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
    
    func walletSuccessfullyConnected() {
        sheet = nil
        parentState.walletSuccessfullyConnected()
    }
}

extension SetupState: ScanQRCodeStateParent {
    // TODO: These all need to be implemented
    func exitScanQRCode() {}
    func postQRCodeScanComplete() {}
    
    func foundQRCode(_ code: String) {
        foundQRCode = code
    }
}
