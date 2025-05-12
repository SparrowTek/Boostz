//
//  UInt64.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 1/9/24.
//

import Foundation

extension UInt64 {
    var invoiceFormat: String {
        let timeInterval = Double(self)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    var currency: String {
        self == 1 ? "\(self.formatted()) sat" : "\(self.formatted()) sats"
    }
    
    var satsToMillisats: UInt64 {
        self * 1000
    }
    
    var millisatsToSats: UInt64 {
        self / 1000
    }
}
