//
//  ReceiveView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 1/10/24.
//

import SwiftUI

struct ReceiveView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Text("Receive")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done", action: { dismiss() })
                    }
                }
        }
    }
}

#Preview {
    ReceiveView()
}
