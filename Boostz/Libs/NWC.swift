//
//  NWC.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/27/24.
//

import SwiftUI
import NostrSDK

@Observable
@MainActor
class NWC {
    func connect(code: String) {
        print("QR CODE: \(code)")
        // TODO: take the code and connect to NWC
        //        nostr+walletconnect://bc7ad36e9fd3ea57d2723d6d79e76dcb3c6fd282f4521b2604dd0b58cc618a4b?relay=wss://relay.getalby.com/v1&secret=8d869177502a16583ff34bfd2b66388ff57e0df2a05ac37b9179c3a71d89131a&lud16=sparrowtek@getalby.com
    }
}

private struct NWCKey: EnvironmentKey {
    static let defaultValue = NWC()
}

extension EnvironmentValues {
    var nwc: NWC {
        get { self[NWCKey.self] }
        set { self[NWCKey.self] = newValue }
    }
}
