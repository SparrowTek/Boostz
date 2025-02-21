//
//  SetupPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/6/24.
//

import SwiftUI
import SwiftData
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
        #warning("This logic needs to be gated somehow for only certain types.. oh maybe by using the eventID?")
//        print("currentPublishedEvent: \(String(describing: nwc.currentPublishedEvent?.kind))")
//        guard nwc.currentPublishedEvent is WalletConnectInfoEvent else { return }
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
    @Environment(\.modelContext) private var context
    @Query private var nwcCodes: [NWCCode]
    
    var body: some View {
        @Bindable var state = state
        
        VStack {
            HStack {
                TextField("enter connection secret", text: $state.connectionSecret)
                    .textFieldStyle(.roundedBorder)
                Button("enter", action: evaluateConnectionSecret)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Text("or")
                .font(.subheadline)
                .padding()
            
            Button("scan QR", systemImage: "camera.viewfinder", action: tappedScanQR)
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
        .onChange(of: state.foundQRCode) { parseWalletCode() }
        .onChange(of: nwc.hasConnected) { connectToWallet() }
        .fullScreenColorView()
    }
    
    private func evaluateConnectionSecret() {
        guard !state.connectionSecret.isEmpty else { return }
        parseWalletCode(state.connectionSecret)
    }
    
    private func tappedScanQR() {
        state.sheet = .scanQR
    }
    
    private func parseWalletCode() {
        guard let code = state.foundQRCode else { return }
        parseWalletCode(code)
    }
    
    private func parseWalletCode(_ code: String) {
        do {
            let nwcCode = try nwc.parseWalletCode(code)
            context.insert(nwcCode)
            try context.save()
        } catch {
            // TODO: handle error
            print("ERROR: \(error)")
        }
    }
    
    private func connectToWallet() {
        guard let nwcCode = nwcCodes.first else { return }
        do {
            try nwc.connectToWallet(pubKey: nwcCode.pubKey)
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
