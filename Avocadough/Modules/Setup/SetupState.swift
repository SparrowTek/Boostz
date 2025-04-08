//
//  SetupState.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/6/24.
//

import Foundation
import SwiftUI

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
    var connectionSecret = ""
    var errorMessage: LocalizedStringKey?
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
    func exitScanQRCode() {
        sheet = nil
    }
    
    func postQRCodeScanComplete() {
        sheet = nil
    }
    
    func foundQRCode(_ code: String) {
        foundQRCode = code
    }
}
