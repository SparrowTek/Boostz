//
//  AuthPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/30/23.
//

import SwiftUI
import AlbyKit

@MainActor
struct AuthPresenter: View {
    @Environment(AuthState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        AuthView()
            .sheet(item: $state.sheet) {
                switch $0 {
                case .auth(let safariView):
                    safariView
                        .ignoresSafeArea(.all)
                }
            }
    }
}

@MainActor
fileprivate struct AuthView: View {
    @Environment(AuthState.self) private var state
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @Environment(\.colorScheme) private var colorScheme
    @State private var getAlbyTokenTrigger = PlainTaskTrigger()
    @State private var loginWithAlbyTrigger = PlainTaskTrigger()
    
    var body: some View {
        VStack {
            Text("Boostz")
                .font(.largeTitle)
                .bold()
                .setForegroundStyle()
            
            Spacer()
            
            HStack {
                Text("connect via:")
                    .font(.title)
                    .setForegroundStyle()
                Spacer()
            }
            .padding(.horizontal)
            
            Button(action: triggerLoginWithAlby) {
                ZStack {
                    Color.albyBackground
                    Image(.alby)
                        .resizable()
                        .scaledToFit()
                }
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .frame(maxWidth: .infinity)
                .frame(height: 88)
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .commonView()
        .onChange(of: state.albyCode, triggerGetAlbyToken)
        .task($getAlbyTokenTrigger) { await getAlbyToken() }
        .task($loginWithAlbyTrigger) { await loginWithAlby() }
    }
    
    private func triggerGetAlbyToken() {
        getAlbyTokenTrigger.trigger()
    }
    
    private func getAlbyToken() async {
        guard let code = state.albyCode, !code.isEmpty else { return } // TODO: handle the guard or return??
        
        do {
            let token = try await OAuthService().requestAccessToken(code: code)
            state.saveAlbyToken(token)
        } catch {
            // TODO: alert user of error
            print("### ERROR: \(error)")
        }
    }
    
    private func triggerLoginWithAlby() {
        loginWithAlbyTrigger.trigger()
    }
    
    private func loginWithAlby() async {
        // TODO: handle the failed try
        
        let primaryBackground = UIColor(Color.primaryBackground)
        let color = colorScheme == .light ? lightThemeColor.color : darkThemeColor.color
        let tintColor = UIColor(color)
        
        guard let safariVC = try? await OAuthService().getAuthCodeWithSwiftUI(
            preferredControlerTintColor: tintColor,
            preferredBarTintColor: primaryBackground,
            withScopes: [.accountRead,
                         .invoicesCreate,
                         .invoicesRead,
                         .transactionsRead,
                         .balanceRead,
                         .paymentsSend]
        ) else { return }
        state.sheet = .auth(safariVC)
    }
}

#Preview {
    AuthPresenter()
        .environment(AuthState(parentState: .init()))
}
