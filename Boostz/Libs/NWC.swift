//
//  NWC.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/27/24.
//

import SwiftUI
import NostrSDK
import Vault

enum NWCError: Error {
    case noPubKey
    case noSecret
    case noSecretToParse
    case failedToSaveSecret
    case noRelay
    case badKeypair
    case badWalletConnectEvent
    case badRelayURL
    case noWalletCode
}

@Observable
class NWC: EventCreating {
    // TODO: get a list of relays that support NWC
    // TODO: setup a Boostz owned relay that supports NWC
    private var relayPool: RelayPool?
    
    private var receivedResponses: Set<RelayResponse> = [] {
        didSet { receivedResponses.subtracting(oldValue).forEach { evaluateResponse($0) } }
    }
    private var receivedEvents: Set<RelayEvent> = [] {
        didSet { receivedEvents.subtracting(oldValue).forEach { evaluateEvent($0) }}
    }
    var currentPublishedEvent: NostrEvent?
    var currentRelayResponse: RelayResponse?
    var currentRelayEvent: RelayEvent?
    var hasConnected = false
    private var walletRelays: [Relay] = []
    private var walletCode: String?
    private var secret: String? {
        try? Vault.getPrivateKey(keychainConfiguration: .nwcSecret)
    }
    
    func connectToRelays(with urls: [String]) throws {
        var relays: Set<Relay> = []

        for relayURL in urls {
            guard let url = URL(string: relayURL), let relay = try? Relay(url: url) else { continue }
            relays.insert(relay)
            walletRelays.append(relay)
        }
        
        relayPool = RelayPool(relays: relays)
        relayPool?.delegate = self
        relayPool?.connect()
    }
    
    func parseWalletCode(_ code: String) throws (NWCError) -> NWCCode {
        walletCode = code
        let nwcCode = try parseCode(code)
        nwcCode.relays.forEach { try? addRelay(for: $0.url) }
        return nwcCode
    }
    
    func connectToWallet(pubKey: String) throws (NWCError) {
        guard let secret else { throw .noSecret }
        guard let keypair = Keypair(hex: secret) else { throw .badKeypair }
        guard let walletConnectEvent = try? walletConnectRequest(walletPubkey: pubKey, method: WalletConnectType.getInfo.rawValue, params: [:], signedBy: keypair) else { throw .badWalletConnectEvent }
//                WalletConnectRequestEvent(walletPubkey: pubKey, method: WalletConnectType.getInfo.rawValue, params: [:], signedBy: keypair) else { throw .badWalletConnectEvent }
//        guard let giftWrapped = try? GiftWrapEvent(content: walletConnectEvent.content, signedBy: keypair) else { throw .badWalletConnectEvent } // TODO: new error type
        publishEvent(walletConnectEvent)
    }
    
//    func getWalletInfo() throws (NWCError) {
//        guard let secret else { throw .noSecret }
//        guard let keypair = Keypair(hex: secret) else { throw .badKeypair }
//        guard let walletConnectInfoEvent = try? WalletConnectInfoEvent(capabilities: [], signedBy: keypair) else { throw .badWalletConnectEvent }
//        publishEvent(walletConnectInfoEvent)
//    }
    
    func listTransactions(pubKey: String) throws (NWCError) {
//        "params": {
//                "from": 1693876973, // starting timestamp in seconds since epoch (inclusive), optional
//                "until": 1703225078, // ending timestamp in seconds since epoch (inclusive), optional
//                "limit": 10, // maximum number of invoices to return, optional
//                "offset": 0, // offset of the first invoice to return, optional
//                "unpaid": true, // include unpaid invoices, optional, default false
//                "type": "incoming", // "incoming" for invoices, "outgoing" for payments, undefined for both
//            }
        guard let secret else { throw .noSecret }
        guard let keypair = Keypair(hex: secret) else { throw .badKeypair }
        
//        let params: [String : Any] = [
//            "limit" : 10,
//            "offset" : 0,
//        ]
        
        let params: [String : Any] = [
            "from": 1693876973, // starting timestamp in seconds since epoch (inclusive), optional
            "until": 1703225078, // ending timestamp in seconds since epoch (inclusive), optional
            "limit": 10, // maximum number of invoices to return, optional
            "offset": 0, // offset of the first invoice to return, optional
            "unpaid": true, // include unpaid invoices, optional, default false
            "type": "incoming", // "incoming" for invoices, "outgoing" for payments, undefined for both
        ]
        
//        guard let walletConnectRequestEvent = try? WalletConnectRequestEvent(walletPubkey: pubKey, method: WalletConnectType.listTransactions.rawValue, params: params, signedBy: keypair) else { throw .badWalletConnectEvent }
//        publishEvent(walletConnectRequestEvent)
    }
    
    func getBalance(pubKey: String) throws (NWCError) {
        guard let secret else { throw .noSecret }
        guard let keypair = Keypair(hex: secret) else { throw .badKeypair }
//        guard let walletConnectRequestEvent = try? WalletConnectRequestEvent(walletPubkey: pubKey, method: WalletConnectType.getBalance.rawValue, params: [:], signedBy: keypair) else { throw .badWalletConnectEvent }
//        publishEvent(walletConnectRequestEvent)
    }
    
//case listTransactions = "list_transactions"
//case getBalance = "get_balance"
    
    private func publishEvent(_ event: NostrEvent) {
        currentPublishedEvent = event
        print("EVENT CONTENT: \(event.content)")
        relayPool?.publishEvent(event)
    }
    
    private func addRelay(for url: String) throws {
        guard let url = URL(string: url) else { throw NWCError.badRelayURL }
        
        if let relayPool {
            let relay = try Relay(url: url)
            walletRelays.append(relay)
            relayPool.add(relay: relay)
        } else {
            try connectToRelays(with: [url.absoluteString])
        }
    }
    
    private func saveSecret(_ secret: String) throws {
        try Vault.savePrivateKey(secret, keychainConfiguration: .nwcSecret)
    }
    
    private func parseCode(_ code: String) throws (NWCError) -> NWCCode {
        guard let pubKeyRange = code.range(of: "://([^?]+)", options: .regularExpression), let pubKey = code[pubKeyRange].split(separator: "/").last else { throw NWCError.noPubKey }
        guard let relayRange = code.range(of: "relay=([^&]+)", options: .regularExpression), let relay = code[relayRange].split(separator: "=").last else { throw NWCError.noRelay }
        let relays = String(relay).split(separator: ",").map { String($0) }
        guard let secretRange = code.range(of: "secret=([^&]+)", options: .regularExpression), let secret = code[secretRange].split(separator: "=").last else { throw NWCError.noSecretToParse }
        var lud16: String?
        if let lud16Range = code.range(of: "lud16=([^&]+)", options: .regularExpression), let lud16Value = code[lud16Range].split(separator: "=").last {
            lud16 = String(lud16Value)
        }
        
        do {
            try saveSecret(String(secret))
        } catch {
            throw .failedToSaveSecret
        }
            
        let relayURLs = relays.map { RelayURL(url: $0) }
        return NWCCode(pubKey: String(pubKey), relays: relayURLs, lud16: lud16)
    }
    
    private func evaluateResponse(_ response: RelayResponse) {
        currentRelayResponse = response
    }
    
    private func evaluateEvent(_ event: RelayEvent) {
        currentRelayEvent = event
    }
}

extension NWC: RelayDelegate {
    func relayStateDidChange(_ relay: Relay, state: Relay.State) {
        switch state {
        case .notConnected:
            relay.connect()
        case .connecting:
            break
        case .connected:
            guard walletRelays.contains(relay) else { return }
            hasConnected = true
        case .error(let error):
            print(error.localizedDescription)
            break
        }
    }
    
    func relay(_ relay: Relay, didReceive response: RelayResponse) {
        switch response {
        case .event(let subscriptionId, let event):
            print("EVENT START")
            print("subscriptionId: \(subscriptionId)")
            print("event: \(event)")
            print("EVENT END")
        case .ok(let eventId, let success, let message):
            print("OK START")
            print("eventId: \(eventId)")
            print("success: \(success)")
            print("message: \(message)")
            print("OK END")
        case .eose(let subscriptionId):
            print("eose START")
            print("subscriptionId: \(subscriptionId)")
            print("eose END")
        case .closed(let subscriptionId, let message):
            print("closed START")
            print("subscriptionId: \(subscriptionId)")
            print("message: \(message)")
            print("closed END")
        case .notice(let message):
            print("notice START")
            print("message: \(message)")
            print("notice END")
        case .auth(let challenge):
            print("auth START")
            print("challenge: \(challenge)")
            print("auth END")
        case .count(let subscriptionId, let count):
            print("count START")
            print("subscriptionId: \(subscriptionId)")
            print("count: \(count)")
            print("count END")
        }
        receivedResponses.insert(response)
    }
        
    func relay(_ relay: Relay, didReceive event: RelayEvent) {
        print("didReceive event: \(event)")
        receivedEvents.insert(event)
    }
}

@MainActor
private struct NWCKey: @preconcurrency EnvironmentKey {
    static let defaultValue = NWC()
}

extension EnvironmentValues {
    var nwc: NWC {
        get { self[NWCKey.self] }
        set { self[NWCKey.self] = newValue }
    }
}
