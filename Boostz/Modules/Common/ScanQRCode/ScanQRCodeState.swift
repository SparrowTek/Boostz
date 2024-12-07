//
//  ScanQRCodeState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/7/24.
//

import Foundation

@MainActor
protocol ScanQRCodeStateParent: AnyObject {
    func exitScanQRCode()
    func postQRCodeScanComplete()
}

@Observable
@MainActor
class ScanQRCodeState {
    private unowned let parentState: ScanQRCodeStateParent
    
    enum Sheet: Int, Identifiable {
        case scanQR
        
        var id: Int { rawValue }
    }
    
    var sheet: Sheet?
    var errorMessage: LocalizedStringResource?
    
    init(parentState: ScanQRCodeStateParent) {
        self.parentState = parentState
    }
    
    func exitView() {
        parentState.exitScanQRCode()
    }
    
    func postQRCodeScanComplete() {
        parentState.postQRCodeScanComplete()
    }
}

