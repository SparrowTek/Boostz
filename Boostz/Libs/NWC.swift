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
}

extension RelayEvent: @retroactive Equatable {}
extension RelayEvent: @retroactive Hashable {
    public static func == (lhs: RelayEvent, rhs: RelayEvent) -> Bool {
        lhs.event == rhs.event && lhs.subscriptionId == rhs.subscriptionId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subscriptionId)
        hasher.combine(event)
    }
}

extension RelayResponse: @retroactive Equatable {}
extension RelayResponse: @retroactive Hashable {
    public static func == (lhs: RelayResponse, rhs: RelayResponse) -> Bool {
        switch (lhs, rhs) {
        case let (.event(id1, event1), .event(id2, event2)):
            return id1 == id2 && event1 == event2
        case let (.ok(id1, success1, message1), .ok(id2, success2, message2)):
            return id1 == id2 && success1 == success2 && message1.prefix == message2.prefix && message1.message == message2.message
        case let (.eose(id1), .eose(id2)):
            return id1 == id2
        case let (.closed(id1, message1), .closed(id2, message2)):
            return id1 == id2 && message1.prefix == message2.prefix && message1.message == message2.message
        case let (.notice(message1), .notice(message2)):
            return message1 == message2
        case let (.auth(challenge1), .auth(challenge2)):
            return challenge1 == challenge2
        case let (.count(id1, count1), .count(id2, count2)):
            return id1 == id2 && count1 == count2
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .event(subscriptionId, event):
            hasher.combine(0)
            hasher.combine(subscriptionId)
            hasher.combine(event)
        case let .ok(eventId, success, message):
            hasher.combine(1)
            hasher.combine(eventId)
            hasher.combine(success)
            hasher.combine(message.prefix)
            hasher.combine(message.message)
        case let .eose(subscriptionId):
            hasher.combine(2)
            hasher.combine(subscriptionId)
        case let .closed(subscriptionId, message):
            hasher.combine(3)
            hasher.combine(subscriptionId)
            hasher.combine(message.prefix)
            hasher.combine(message.message)
        case let .notice(message):
            hasher.combine(4)
            hasher.combine(message)
        case let .auth(challenge):
            hasher.combine(5)
            hasher.combine(challenge)
        case let .count(subscriptionId, count):
            hasher.combine(6)
            hasher.combine(subscriptionId)
            hasher.combine(count)
        }
    }
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
//    private var walletRelays: [Relay] = []
//    private var continuation: CheckedContinuation<Void, Never>?
//    private var hasConnected = false {
//        didSet {
//            if hasConnected {
//                continuation?.resume()
//                continuation = nil
//            }
//        }
//    }
    
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
    
    func connectToWallet(code: String) throws (NWCError) {
        let nwcCode = try parseCode(code)
        nwcCode.relays.forEach { try? addRelay(for: $0) } ; #warning("Should this try be ignored?")
        guard let keypair = Keypair(hex: nwcCode.secret) else { throw .badKeypair }
        guard let walletConnectEvent = try? WalletConnectRequestEvent(walletPubkey: nwcCode.pubKey, method: WalletConnectType.getInfo.rawValue, params: [:], signedBy: keypair) else { throw .badWalletConnectEvent }
//        await waitForConnection()
        publishEvent(walletConnectEvent)
    }
    
//    private func waitForConnection() async {
//        guard !hasConnected else { return }
//        await withCheckedContinuation { continuation in
//            self.continuation = continuation
//        }
//    }
    
    private func publishEvent(_ event: NostrEvent) {
        currentPublishedEvent = event
        relayPool?.publishEvent(event)
    }
    
    private func addRelay(for url: String) throws {
        guard let url = URL(string: url) else { throw NWCError.badRelayURL }
        let relay = try Relay(url: url)
//        walletRelays.append(relay)
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
            break
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
