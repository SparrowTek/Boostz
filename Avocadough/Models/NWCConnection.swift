//
//  NWCConnection.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 1/11/25.
//

@preconcurrency import SwiftData

typealias NWCConnection = NWCConnectionSchemaV1.NWCConnection

enum NWCConnectionSchemaV1: VersionedSchema, Sendable {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [NWCConnection.self]
    }

    @Model
    class NWCConnection {
        var pubKey: String
        var relay: String
        var lud16: String?
        
        init(pubKey: String, relay: String, lud16: String?) {
            self.pubKey = pubKey
            self.relay = relay
            self.lud16 = lud16
        }
    }
}
