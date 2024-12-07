//
//  SetupPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/6/24.
//

import SwiftUI

struct SetupPresenter: View {
    @Environment(SetupState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack {
            SetupView()
                .sheet(item: $state.sheet) {
                    switch $0 {
                    case .scanQR:
                        ScanQRCodeView()
                    }
                }
        }
    }
}

fileprivate struct SetupView: View {
    @Environment(SetupState.self) private var state
    
    var body: some View {
        VStack {
            Button("Scan QR", systemImage: "camera.viewfinder", action: tappedScanQR)
                .buttonStyle(.borderedProminent)
        }
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
    
    private func tappedScanQR() {
        state.sheet = .scanQR
    }
}

#Preview {
    SetupPresenter()
        .environment(SetupState(parentState: AppState()))
        .environment(ScanQRCodeState(parentState: SetupState(parentState: .init())))
}
