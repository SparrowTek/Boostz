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
    @Environment(AlbyKit.self) private var alby
    
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
    }
    
    private func getAccountInfo() async {
        do {
            // TODO: commiting this but it is WIP
            let accountSummary = try await alby.accountService.getAccountSummary()
            async let accountBalance = try alby.accountService.getAccountBalance()
            async let me = try alby.accountService.getPersonalInformation()
            print("accountSummary: \(String(describing: accountSummary))")
            print("accountBalance: \(String(describing: try await accountBalance))")
            print("me: \(String(describing: try await me))")
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
