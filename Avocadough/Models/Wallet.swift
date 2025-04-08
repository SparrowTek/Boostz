//
//  Wallet.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 2/22/25.
//

import SwiftData
import NostrSDK

#warning("gate functionality based on the methods approved by the wallet")
enum WalletMethod: String, Codable {
    case payInvoice = "pay_invoice"
    case payKeysend = "pay_keysend"
    case multiPayInvoice = "multi_pay_invoice"
    case multiPayKeysend = "multi_pay_keysend"
    case getInfo = "get_info"
    case getBalance = "get_balance"
    case makeInvoice = "make_invoice"
    case lookupInvoice = "lookup_invoice"
    case listTransactions = "list_transactions"
    case signMessage = "sign_message"
    case getBudget = "get_budget"
//    case unknown = "unknown"
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let rawValue = try container.decode(String.self)
//        self = WalletMethod(rawValue: rawValue) ?? .unknown
//    }
}

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
    var methods: [WalletMethod]
    
    /// Active network
    var network: String
    
    /// Lightning Node’s public key
    @Attribute(.unique) var pubkey: String
    
    init(balance: UInt64, alias: String, blockHash: String, blockHeight: UInt32, color: String, methods: [WalletMethod], network: String, pubkey: String) {
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
        self.methods = info.methods.compactMap { WalletMethod(rawValue: $0) }
        self.network = info.network
        self.pubkey = info.pubkey
    }
}
