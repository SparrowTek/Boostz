//
//  SendState.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/14/24.
//

import Foundation
import AlbyKit

@Observable
@MainActor
class SendState {
    enum NavigationLink: Hashable {
        case sendInvoice(String)
        case getLightningAddressDetails(String)
        case scanQR
    }
    
    enum LightningAddressError: Error {
        case badLightningAddress
        case unsupported
    }
    
    enum LightningAddressType: Sendable {
        case bolt11Invoice(String)
        case bolt11LookupRequired(String)
    }
    
    private unowned let parentState: WalletState
    var path: [SendState.NavigationLink] = []
    var accountBalance = ""
    var errorMessage: LocalizedStringResource?
    
    init(parentState: WalletState) {
        self.parentState = parentState
        self.accountBalance = setAccountBalance()
    }
    
    func cancel() {
        clearPathAndCloseSheet()
    }
    
    func paymentSent() {
        parentState.paymentSent()
        clearPathAndCloseSheet()
    }
    
    func postQRCodeScanComplete() {
        path.removeAll { $0 == .scanQR }
    }
    
    func continueWithInput(_ lightningInput: String, replaceCurrentPath: Bool = false) {
        do {
            switch try findLightningAddressInText(lightningInput) {
            case .bolt11Invoice(let invoice):
                if replaceCurrentPath {
                    path[path.index(before: path.endIndex)] = .sendInvoice(invoice)
                } else {
                    path.append(.sendInvoice(invoice))
                }
            case .bolt11LookupRequired(let lightningAddress):
                if replaceCurrentPath {
                    path[path.index(before: path.endIndex)] = .getLightningAddressDetails(lightningAddress)
                } else {
                    path.append(.getLightningAddressDetails(lightningAddress))
                }
            }
        } catch LightningAddressError.unsupported {
            errorMessage = "This address format is currently unsupported"
        } catch {
            badLightningAddress()
        }
    }
    
    private func badLightningAddress() {
        errorMessage = "The address you entered is not valid. Please try again."
    }
    
    private func findLightningAddressInText(_ text: String) throws -> LightningAddressType {
        let text = text.lowercased()
        
        // Define the regex patterns
        let lightningPattern = #"(?i)((⚡|⚡️):?|lightning:?|lnurl:?)\s?(\S+)"#
        let albyUserPattern = #"^(https?:\/\/)?(www\.)?(\w+)@getalby\.com$"#
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        if let _ = try? text.firstMatch(of: Regex(lightningPattern)) {
            return try getBolt11Lookup(for: text)
        }
        
        if let _ = try? text.firstMatch(of: Regex(emailRegEx)) {
            return .bolt11LookupRequired(text)
        }
        
        if let _ = try? text.firstMatch(of: Regex(albyUserPattern)) {
//            return try getBolt11Lookup(for: text)
            throw LightningAddressError.unsupported
        }
        
        return .bolt11Invoice(text)
    }
    
    private func getBolt11Lookup(for text: String) throws -> LightningAddressType {
        var text = text.lowercased()
        
        if text.hasPrefix("lnurl") ||
            text.hasPrefix("lightning") ||
            text.hasPrefix("⚡") {
            let components = text.components(separatedBy: ":")
            
            if components.count > 1 {
                var lookup = ""
                
                for component in components {
                    guard component != components[0] else { continue }
                    
                    if component == components[1] {
                        lookup = component
                    } else {
                        lookup = "\(lookup):\(component)"
                    }
                }
                
                guard !lookup.isEmpty else { throw LightningAddressError.badLightningAddress }
                
                return .bolt11LookupRequired(lookup)
            } else {
                text.removePrefix("lnurl")
                text.removePrefix("lightning")
                text.removePrefix("⚡")
                return .bolt11LookupRequired(text)
            }
        }
        
        return .bolt11LookupRequired(text)
    }
    
    private func setAccountBalance() -> String {
        let balance = parentState.accountBalance?.balance ?? 0
        return "balance: \(balance) sats"
    }
    
    private func clearPathAndCloseSheet() {
        path = []
        parentState.sheet = nil
    }
}
