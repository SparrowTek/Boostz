//
//  ContentView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/9/23.
//

import SwiftUI
import AlbyKit

struct AppPresenter: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        switch state.route {
        case .setup:
            SetupPresenter()
        case .wallet:
            WalletPresenter()
        }
    }
}

#Preview {
    AppPresenter()
        .environment(AppState())
        .environment(AlbyKit())
        .environment(SetupState(parentState: .init()))
}
