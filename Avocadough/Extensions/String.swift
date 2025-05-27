//
//  String.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 4/15/25.
//

import Foundation

extension String {
    
    func asDollars(for sats: UInt64) -> String? {        
        guard let btcPrice = Double(self) else { return nil }
        let btcAmount = Double(sats) / 100_000_000
        let usdValue = btcPrice * btcAmount
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: usdValue))
    }
}
