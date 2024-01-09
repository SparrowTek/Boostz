//
//  Date.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/9/24.
//

import Foundation

extension Date {
    var invoiceFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yy - HH:mm"
        return dateFormatter.string(from: self)
    }
}
