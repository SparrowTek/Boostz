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
    var relays: [RelayURL]
    var lud16: String?
    
    init(pubKey: String, relays: [RelayURL], lud16: String?) {
        self.pubKey = pubKey
        self.relays = relays
        self.lud16 = lud16
    }
}
