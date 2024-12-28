//
//  NWC.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/27/24.
//

import SwiftUI
import NostrSDK
import Vault

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
    
    func connectToWallet(code: String) {
        print("QR CODE: \(code)")
        // TODO: take the code and connect to NWC
        //        nostr+walletconnect://bc7ad36e9fd3ea57d2723d6d79e76dcb3c6fd282f4521b2604dd0b58cc618a4b?relay=wss://relay.getalby.com/v1&secret=8d869177502a16583ff34bfd2b66388ff57e0df2a05ac37b9179c3a71d89131a&lud16=sparrowtek@getalby.com
        
        do {
            let walletConnectEvet = try WalletConnectRequestEvent(walletPubkey: "bc7ad36e9fd3ea57d2723d6d79e76dcb3c6fd282f4521b2604dd0b58cc618a4b", method: WalletConnectType.getInfo.rawValue, params: [ : ], signedBy: Keypair(hex: "8d869177502a16583ff34bfd2b66388ff57e0df2a05ac37b9179c3a71d89131a")!)
            relayPool?.publishEvent(walletConnectEvet)
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    private func addRelay(for url: String) throws {
        guard let url = URL(string: url) else { return } // TODO: throw error here
        let relay = try Relay(url: url)
        relayPool?.add(relay: relay)
    }
    
    private func saveSecret(_ secret: String) throws {
        try Vault.savePrivateKey(secret, keychainConfiguration: .nwcSecret)
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
