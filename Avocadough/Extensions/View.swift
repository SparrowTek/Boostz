//
//  View.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 3/2/25.
//

import SwiftUI

extension View {
    var isCanvas: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
