//
//  BlockBTCPriceService.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 4/11/25.
//

import Foundation

struct BlockBTCPriceService {
    enum BlockBTCPriceError: Error {
        case badURL
        case noStatusCode
        case badStatusCode(Int)
    }
    
    func getCurrentPrice() async throws -> BTCPrice {
        let request = try await buildRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw BlockBTCPriceError.noStatusCode }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(BTCPrice.self, from: data)
        default:
            throw BlockBTCPriceError.badStatusCode(httpResponse.statusCode)
        }
    }
    
    private func buildRequest() async throws -> URLRequest {
        guard let url = URL(string: "https://pricing.bitcoin.block.xyz/current-price") else { throw BlockBTCPriceError.badURL }
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = "get"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
