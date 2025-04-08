//
//  OptionalString.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI

extension String? {
    var color: Color {
        guard let self,
              let colorData = self.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return .accent }
        return Color(colorResolved)
    }
}
