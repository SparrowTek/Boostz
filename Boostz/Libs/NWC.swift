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
    case noRelay
    case badKeypair
    case badWalletConnectEvent
    case badRelayURL
    case noWalletCode
}

@Observable
class NWC {
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
    private var continuation: CheckedContinuation<Void, Never>?
    private var walletCode: String?
    
    func connectToRelays(with urls: [String]) throws {
        var relays: Set<Relay> = []

        for relayURL in urls {
            guard let url = URL(string: relayURL), let relay = try? Relay(url: url) else { continue }
            relays.insert(relay)
        }
        
        relayPool = RelayPool(relays: relays)
        relayPool?.delegate = self
        relayPool?.connect()
    }
    
    func parseWalletCode(_ code: String) throws (NWCError) {
        walletCode = code
        let nwcCode = try parseCode(code)
        nwcCode.relays.forEach { try? addRelay(for: $0) }
    }
    
    func connectToWallet() throws (NWCError) {
        guard let walletCode else { throw .noWalletCode }
        let nwcCode = try parseCode(walletCode)
        guard let keypair = Keypair(hex: nwcCode.secret) else { throw .badKeypair }
        guard let walletConnectEvent = try? WalletConnectRequestEvent(walletPubkey: nwcCode.pubKey, method: WalletConnectType.getInfo.rawValue, params: [:], signedBy: keypair) else { throw .badWalletConnectEvent }
        publishEvent(walletConnectEvent)
    }
    
    func getWalletInfo() throws (NWCError) {
        // NWCCode needs to be persisted because walletCode will only be around when you first parse the wallet code
        guard let walletCode else { throw .noWalletCode }
        let nwcCode = try parseCode(walletCode)
        guard let keypair = Keypair(hex: nwcCode.secret) else { throw .badKeypair }
        guard let walletConnectInfoEvent = try? WalletConnectInfoEvent(capabilities: [], signedBy: keypair) else { throw .badWalletConnectEvent }
        publishEvent(walletConnectInfoEvent)
    }
    
    private func publishEvent(_ event: NostrEvent) {
        currentPublishedEvent = event
        relayPool?.publishEvent(event)
    }
    
    private func addRelay(for url: String) throws {
        guard let url = URL(string: url) else { throw NWCError.badRelayURL }
        let relay = try Relay(url: url)
        walletRelays.append(relay)
        relayPool?.add(relay: relay)
    }
    
    private func saveSecret(_ secret: String) throws {
        try Vault.savePrivateKey(secret, keychainConfiguration: .nwcSecret)
    }
    
    private func parseCode(_ code: String) throws (NWCError) -> NWCCode {
        guard let pubKeyRange = code.range(of: "://([^?]+)", options: .regularExpression), let pubKey = code[pubKeyRange].split(separator: "/").last else { throw NWCError.noPubKey }
        guard let relayRange = code.range(of: "relay=([^&]+)", options: .regularExpression), let relay = code[relayRange].split(separator: "=").last else { throw NWCError.noRelay }
        let relays = String(relay).split(separator: ",").map { String($0) }
        guard let secretRange = code.range(of: "secret=([^&]+)", options: .regularExpression), let secret = code[secretRange].split(separator: "=").last else { throw NWCError.noSecret }
        var lud16: String?
        if let lud16Range = code.range(of: "lud16=([^&]+)", options: .regularExpression), let lud16Value = code[lud16Range].split(separator: "=").last {
            lud16 = String(lud16Value)
        }
        
        return NWCCode(pubKey: String(pubKey), relays: relays, secret: String(secret), lud16: lud16)
    }
    
    struct NWCCode {
        let pubKey: String
        let relays: [String]
        let secret: String
        let lud16: String?
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
            for walletRelay in walletRelays {
                if relay == walletRelay {
                    hasConnected = true
                    break
                }
            }
        case .error(let error):
            print(error.localizedDescription)
            break // TODO: log this error
        }
    }

    func relay(_ relay: Relay, didReceive response: RelayResponse) {
        receivedResponses.insert(response)
    }

    func relay(_ relay: Relay, didReceive event: RelayEvent) {
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
