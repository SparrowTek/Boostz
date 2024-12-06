//
//  SetupPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/6/24.
//

import SwiftUI

struct SetupPresenter: View {
    var body: some View {
        NavigationStack {
            SetupView()
        }
    }
}

fileprivate struct SetupView: View {
    var body: some View {
        Text("SETUP")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Boostz")
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
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SetupPresenter()
        .environment(SetupState(parentState: AppState()))
}
