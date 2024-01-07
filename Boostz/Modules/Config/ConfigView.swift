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
    @Environment(AlbyKit.self) private var alby // TODO: delete this
    
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
        .task { await getAccountInfo() }
//        .syncConfigData()
//        .onAppear { state.triggerDataSync = true }
    }
    
    // TODO: delete this method
    private func getAccountInfo() async {
        do {
            // TODO: commiting this but it is WIP
            async let accountSummary = try alby.accountService.getAccountSummary()
            async let accountBalance = try alby.accountService.getAccountBalance()
            async let me = try alby.accountService.getPersonalInformation()
            state.setAccountSummary(try await accountSummary)
            state.setAccountBalance(try await accountBalance)
            state.setMe(try await me)
            state.route = .wallet
        } catch {
            if case .statusCode(let code, _) = error as? NetworkError, code == .unauthorized {
                state.logout()
            } else {
                state.route = .wallet
            }
        }
    }
}

#Preview {
    ConfigView()
        .environment(AppState())
        .environment(AlbyKit())
}
