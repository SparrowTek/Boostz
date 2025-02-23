//
//  Transaction.swift
//  Boostz
//
//  Created by Thomas Rademaker on 2/21/25.
//

import SwiftData
import NostrSDK

enum BoostzTransactionType: String, Codable {
    case incoming
    case outgoing
    
    init(transactionType: TransactionType) {
        self = switch transactionType {
        case .incoming: .incoming
        case .outgoing: .outgoing
        }
    }
}

@Model
class Transaction {
    var transactionType: BoostzTransactionType?
    var invoice: String?
    var transactionDescription: String?
    var descriptionHash: String?
    var preimage: String?
    @Attribute(.unique) var paymentHash: String
    /// Amount in millisatoshis
    var amount: UInt64
    /// Fees paid in millisatoshis
    var feesPaid: UInt64
    var createdAt: UInt64?
    var expiresAt: UInt64?
    var settledAt: UInt64?
    
    init(transactionType: BoostzTransactionType? = nil, invoice: String? = nil, transactionDescription: String? = nil, descriptionHash: String? = nil, preimage: String? = nil, paymentHash: String, amount: UInt64, feesPaid: UInt64, createdAt: UInt64? = nil, expiresAt: UInt64? = nil, settledAt: UInt64? = nil) {
        self.transactionType = transactionType
        self.invoice = invoice
        self.transactionDescription = transactionDescription
        self.descriptionHash = descriptionHash
        self.preimage = preimage
        self.paymentHash = paymentHash
        self.amount = amount
        self.feesPaid = feesPaid
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.settledAt = settledAt
    }
    
    init(lookupInvoiceResponse: LookupInvoiceResponse) {
        self.transactionType = if let transactionType = lookupInvoiceResponse.transactionType {
            BoostzTransactionType(transactionType: transactionType)
        } else {
            nil
        }
        
        self.invoice = lookupInvoiceResponse.invoice
        self.transactionDescription = lookupInvoiceResponse.description
        self.descriptionHash = lookupInvoiceResponse.descriptionHash
        self.preimage = lookupInvoiceResponse.preimage
        self.paymentHash = lookupInvoiceResponse.paymentHash
        self.amount = lookupInvoiceResponse.amount
        self.feesPaid = lookupInvoiceResponse.feesPaid
        self.createdAt = lookupInvoiceResponse.createdAt.asSecs()
        self.expiresAt = lookupInvoiceResponse.expiresAt?.asSecs()
        self.settledAt = lookupInvoiceResponse.settledAt?.asSecs()
    }
}
