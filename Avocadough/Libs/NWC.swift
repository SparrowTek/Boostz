//
//  NWC.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/27/24.
//

import SwiftUI
@preconcurrency import NostrSDK
import LightningDevKit
import Vault

enum NWCError: Error {
    case publicKey
    case noSecret
    case failedToCreateNWCSecretKey
    case failedToCreateNWCUri
    case failedToSaveSecret
    case noNwc
    case failedToParse
    case nostrSDK(Error)
}

@Observable
@MainActor
class NWC {
    private var nwc: Nwc?
    var hasConnected = false
    
    func parseWalletCode(_ code: String) throws (NWCError) -> NWCConnection {
        guard let parsedCode = try? NostrWalletConnectUri.parse(uri: code) else { throw .failedToParse }
        try saveSecret(parsedCode.secret().toHex())
        return NWCConnection(pubKey: parsedCode.publicKey().toHex(), relay: parsedCode.relayUrl(), lud16: parsedCode.lud16())
    }
    
    func initializeNWCClient(pubKey: String, relay: String, lud16: String?) throws (NWCError) {
        guard let publicKey = try? PublicKey.parse(publicKey: pubKey) else { throw .publicKey }
        guard let secret else { throw .noSecret }
        guard let secretKey = try? SecretKey.parse(secretKey: secret) else { throw .failedToCreateNWCSecretKey }
        guard let nwcUri = try? NostrWalletConnectUri(publicKey: publicKey, relayUrl: relay, randomSecretKey: secretKey, lud16: lud16) else { throw .failedToCreateNWCUri }
        nwc = Nwc(uri: nwcUri)
        hasConnected = true
    }
    
    func getInfo() async throws (NWCError) -> GetInfoResponse {
        guard let nwc else { throw .noNwc }
        do {
            return try await nwc.getInfo()
        } catch {
            throw .nostrSDK(error)
        }
    }
    
    func getBalance() async throws (NWCError) -> UInt64 {
        guard let nwc else { throw .noNwc }
        do {
            return try await nwc.getBalance()
        } catch {
            throw .nostrSDK(error)
        }
    }
    
    func payInvoice(_ invoice: Bolt11Invoice) async throws (NWCError) -> PayInvoiceResponse {
        guard let nwc else { throw .noNwc }
        do {
            let payInvoiceRequest = PayInvoiceRequest(id: nil, invoice: invoice.toStr(), amount: invoice.amountMilliSatoshis())
            return try await nwc.payInvoice(params: payInvoiceRequest)
        } catch {
            throw .nostrSDK(error)
        }
    }
        
    func makeInvoice(amount: UInt64, description: String?, descriptionHash: String?, expiry: UInt64?) async throws (NWCError) -> MakeInvoiceResponse {
        guard let nwc else { throw .noNwc }
        
        do {
            let makeInvoiceParams = MakeInvoiceRequest(amount: amount, description: description, descriptionHash: descriptionHash, expiry: expiry)
            return try await nwc.makeInvoice(params: makeInvoiceParams)
        } catch {
            throw .nostrSDK(error)
        }
    }
    
    func listTransactions(from: Timestamp?, until: Timestamp?, limit: UInt64?, offset: UInt64?, unpaid: Bool?, transactionType: TransactionType?) async throws (NWCError) -> [LookupInvoiceResponse] {
        guard let nwc else { throw .noNwc }
        
        do {
            let listTransactionsParams = ListTransactionsRequest(from: from, until: until, limit: limit, offset: offset, unpaid: unpaid, transactionType: transactionType)
            return try await nwc.listTransactions(params: listTransactionsParams)
        } catch {
            throw .nostrSDK(error)
        }
    }
    
    // MARK: Secret
    private var secret: String? { try? Vault.getPrivateKey(keychainConfiguration: .nwcSecret) }
    
    private func saveSecret(_ secret: String) throws (NWCError) {
        do {
            try Vault.savePrivateKey(secret, keychainConfiguration: .nwcSecret)
        } catch {
            throw .failedToSaveSecret
        }
    }
}

@MainActor
private struct NWCKey: @preconcurrency EnvironmentKey {
    static let defaultValue = NWC()
}

extension EnvironmentValues {
    var nwc: NWC {
        get { self[NWCKey.self] }
        set { self[NWCKey.self] = newValue }
    }
}
