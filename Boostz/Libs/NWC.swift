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

@Observable
@MainActor
class NWC {
    // TODO: get a list of relays that support NWC
    // TODO: setup a Boostz owned relay that supports NWC
    private var relayPool: RelayPool?
    
    func connectToRelays(with urls: [String]) throws {
        var relays: Set<Relay> = []

        for relayURL in urls {
            guard let url = URL(string: relayURL), let relay = try? Relay(url: url) else { continue }
            relays.insert(relay)
        }
        
        relayPool = RelayPool(relays: relays)
        relayPool?.connect()
    }
    
    func connectToWallet(code: String) throws (NWCError) {
        let nwcCode = try parseCode(code)
        for relayURL in nwcCode.relays {
            try? addRelay(for: relayURL); #warning("Should this try be ignored?")
        }
        guard let keypair = Keypair(hex: nwcCode.secret) else { throw .badKeypair }
        guard let walletConnectEvent = try? WalletConnectRequestEvent(walletPubkey: nwcCode.pubKey, method: WalletConnectType.getInfo.rawValue, params: [:], signedBy: keypair) else { throw .badWalletConnectEvent }
        relayPool?.publishEvent(walletConnectEvent)
    }
    
    private func addRelay(for url: String) throws {
        guard let url = URL(string: url) else { throw NWCError.badRelayURL }
        let relay = try Relay(url: url)
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
