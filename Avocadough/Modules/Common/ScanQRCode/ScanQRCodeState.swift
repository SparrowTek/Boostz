//
//  ScanQRCodeState.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/7/24.
//

import Foundation
import SwiftUI

@MainActor
protocol ScanQRCodeStateParent: AnyObject {
    func exitScanQRCode()
    func postQRCodeScanComplete()
    func foundQRCode(_ code: String)
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
    var errorMessage: LocalizedStringKey?
    
    init(parentState: ScanQRCodeStateParent) {
        self.parentState = parentState
    }
    
    func exitView() {
        parentState.exitScanQRCode()
    }
    
    func postQRCodeScanComplete() {
        parentState.postQRCodeScanComplete()
    }
    
    func foundQRCode(_ code: String) {
        parentState.foundQRCode(code)
    }
}

