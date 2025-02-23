//
//  Wallet.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/22/25.
//

import SwiftData
import NostrSDK

@Model
class Wallet {
    /// Currnet wallet balance in Milisats
    var balance: UInt64
    
    /// The alias of the lightning node
    var alias: String
    
    /// Most Recent Block Hash
    var blockHash: String
    
    /// Current block height
    var blockHeight: UInt32
    
    /// The color of the current node in hex code format
    var color: String
    
    /// Available methods for this connection
    var methods: [String]
    
    /// Active network
    var network: String
    
    /// Lightning Node’s public key
    @Attribute(.unique) var pubkey: String
    
    init(balance: UInt64, alias: String, blockHash: String, blockHeight: UInt32, color: String, methods: [String], network: String, pubkey: String) {
        self.balance = balance
        self.alias = alias
        self.blockHash = blockHash
        self.blockHeight = blockHeight
        self.color = color
        self.methods = methods
        self.network = network
        self.pubkey = pubkey
    }
    
    init(info: GetInfoResponse, balance: UInt64) {
        self.balance = balance
        self.alias = info.alias
        self.blockHash = info.blockHash
        self.blockHeight = info.blockHeight
        self.color = info.color
        self.methods = info.methods
        self.network = info.network
        self.pubkey = info.pubkey
    }
}
