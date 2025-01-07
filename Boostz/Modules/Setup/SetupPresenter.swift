//
//  SetupPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/6/24.
//

import SwiftUI
import NostrSDK

struct SetupPresenter: View {
    @Environment(SetupState.self) private var state
    @Environment(\.nwc) private var nwc
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack {
            SetupView()
                .sheet(item: $state.sheet) {
                    switch $0 {
                    case .scanQR:
                        ScanQRCodeView()
                            .environment(state.scanQRCodeState)
                    }
                }
                .onChange(of: nwc.currentRelayResponse) { evaluateNWCResponse() }
        }
    }
    
    private func evaluateNWCResponse() {
        guard nwc.currentPublishedEvent is WalletConnectInfoEvent else { return }
        switch nwc.currentRelayResponse {
        case .ok(let eventId, let success, let message):
            // TODO: maybe log eventId and message?
            if success {
                state.walletSuccessfullyConnected()
            } else {
                // TODO: handle error
            }
        default: break
        }
    }
}

fileprivate struct SetupView: View {
    @Environment(SetupState.self) private var state
    @Environment(\.nwc) private var nwc
    
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
            .task(id: state.foundQRCode) { await connectToWallet() }
    }
    
    private func tappedScanQR() {
        state.sheet = .scanQR
    }
    
    private func connectToWallet() async {
        guard let code = state.foundQRCode else { return }
        
        do {
            try await nwc.connectToWallet(code: code)
        } catch {
            // TODO: handle error
            print("ERROR: \(error)")
        }
    }
}

#Preview {
    SetupPresenter()
        .environment(SetupState(parentState: AppState()))
        .environment(ScanQRCodeState(parentState: SetupState(parentState: .init())))
        .environment(\.nwc, NWC())
}
