//
//  ConfigView.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/31/23.
//

import SwiftUI

struct ConfigView: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("preparing your wallet")
                ProgressView()
                    .padding(.leading, 4)
            }
            .font(.title3)
            .setForegroundStyle()
            .fullScreenColorView()
            .syncConfigData()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Avocadough")
                            .font(.largeTitle)
                            .bold()
                        Image(systemName: "bolt.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.yellow)
                        Image(systemName: "bolt.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.yellow)
                    }
                    .setForegroundStyle()
                }
            }
        }
    }
}

#Preview {
    ConfigView()
        .environment(AppState())
}
