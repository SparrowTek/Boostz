//
//  ConfigView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/31/23.
//

import SwiftUI
import AlbyKit

struct ConfigView: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        VStack {
            Text("Boostz")
                .font(.largeTitle)
                .bold()
                .setForegroundStyle()
            
            Spacer()
            
            HStack {
                Text("preparing your wallet")
                ProgressView()
                    .padding(.leading, 4)
            }
            .font(.title3)
            .setForegroundStyle()
            
            Spacer()
        }
        .padding()
        .commonView()
        .syncConfigData()
        .onAppear { state.triggerDataSync = true }
    }
}

#Preview {
    ConfigView()
        .environment(AppState())
        .environment(AlbyKit())
}
