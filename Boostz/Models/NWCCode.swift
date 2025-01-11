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
    var relays: [String]
    var lud16: String?
    
    init(pubKey: String, relays: [String], lud16: String?) {
        self.pubKey = pubKey
        self.relays = relays
        self.lud16 = lud16
    }
}
