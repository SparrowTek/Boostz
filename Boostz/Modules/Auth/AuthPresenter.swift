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
    @Environment(AlbyKit.self) private var alby
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @Environment(\.colorScheme) private var colorScheme
    @State private var getAlbyTokenTrigger = PlainTaskTrigger()
    
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
            
            Button(action: loginWithAlby) {
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
    }
    
    private func triggerGetAlbyToken() {
        getAlbyTokenTrigger.trigger()
    }
    
    private func getAlbyToken() async {
        guard let code = state.albyCode, !code.isEmpty else { return } // TODO: handle the guard or return??
        
        do {
            let token = try await alby.oauthService.requestAccessToken(code: code)
            state.saveAlbyToken(token)
        } catch {
            // TODO: alert user of error
            print("### ERROR: \(error)")
        }
    }
    
    private func loginWithAlby() {
        // TODO: handle the failed try
        
        let primaryBackground = UIColor(Color.primaryBackground)
        let color = colorScheme == .light ? lightThemeColor.color : darkThemeColor.color
        let tintColor = UIColor(color)
        
        guard let safariVC = try? alby.oauthService.getAuthCodeWithSwiftUI(
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
        .environment(AlbyKit())
}
