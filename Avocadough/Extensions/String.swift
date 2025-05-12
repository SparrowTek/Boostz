//
//  String.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 4/15/25.
//

import Foundation

extension String {
    
    func asDollars(for sats: UInt64) -> String? {
        guard let amount = Double(self) else { return nil }
        return "$\(amount)" // TODO: THIS IS WRONG
    }
}
