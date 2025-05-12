//
//  GeneratedInvoice.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 4/12/25.
//

struct GeneratedInvoice: Codable, Sendable {
    public let invoice: GeneratedInvoiceBody?
}

struct GeneratedInvoiceBody: Codable, Sendable {
    public let pr: String?
    public let routes: [String]?
    public let status: String?
    public let successAction: SuccessAction?
    public let verify: String?
}

struct SuccessAction: Codable, Sendable {
    public let message: String?
    public let tag: String?
}
