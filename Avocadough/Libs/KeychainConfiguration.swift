//
//  Vault.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 1/4/24.
//

import Vault

extension KeychainConfiguration {
    static let serviceName = "com.sparrowtek.avocadough"
    // TODO: add an access group
    static let nwcSecret = KeychainConfiguration(serviceName: serviceName, accessGroup: nil, accountName: "\(serviceName).nwcSecret")
}
