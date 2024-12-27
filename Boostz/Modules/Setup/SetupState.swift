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
    var nwc: NWC
    @ObservationIgnored
    lazy var scanQRCodeState = ScanQRCodeState(parentState: self)
    
    init(parentState: AppState, nwc: NWC) {
        self.parentState = parentState
        self.nwc = nwc
    }
}

extension SetupState: ScanQRCodeStateParent {
    // TODO: These all need to be implemented
    func exitScanQRCode() {}
    func postQRCodeScanComplete() {}
    
    func foundQRCode(_ code: String) {
        nwc.connect(code: code)
    }
}
