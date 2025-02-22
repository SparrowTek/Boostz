//
//  NWCCode.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/11/25.
//

import SwiftData

@Model
class NWCCode {
    var pubKey: String
    var relay: String
    var lud16: String?
    
    init(pubKey: String, relay: String, lud16: String?) {
        self.pubKey = pubKey
        self.relay = relay
        self.lud16 = lud16
    }
}

//@Model
//class NWCURI {
//    var publicKey: String
//    var relayUrl: String
//    var lud16: String?
//    
//    init(publicKey: String, relayUrl: String, lud16: String?) {
//        self.publicKey = publicKey
//        self.relayUrl = relayUrl
//        self.lud16 = lud16
//    }
//}

//init(publicKey: PublicKey, relayUrl: String, randomSecretKey: SecretKey, lud16: String?)throws  {
