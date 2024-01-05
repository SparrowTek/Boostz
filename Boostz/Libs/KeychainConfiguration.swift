//
//  Vault.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/4/24.
//

import Vault

extension KeychainConfiguration {
    static let serviceName = "com.sparrowtek.boostz"
    static let albyToken = KeychainConfiguration(serviceName: serviceName, accessGroup: nil, accountName: "\(serviceName).albyToken")
    static let albyRefreshToken = KeychainConfiguration(serviceName: serviceName, accessGroup: nil, accountName: "\(serviceName).albyRefreshToken")
}
