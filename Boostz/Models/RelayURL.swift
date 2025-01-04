//
//  RelayURL.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/28/24.
//

import SwiftData

@Model
class RelayURL {
    var url: String
#warning("We should track how often we fail to connect and remove from SwiftData if X failures occur in a row (meaning the relay is no longer available)")
//    var consecutiveRetries: Int
    
    init(url: String) {
        self.url = url
    }
}
