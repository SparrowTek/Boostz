//
//  AuthPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/30/23.
//

import SwiftUI
import AlbyKit

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

fileprivate struct AuthView: View {
    @Environment(AuthState.self) private var state
    @Environment(AlbyKit.self) private var alby
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            Text("Boostz")
                .font(.largeTitle)
                .bold()
                .setForegroundStyle()
            
            Spacer()
            
            HStack {
                Text("Connect Via:")
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
        .commonView()
    }
    
    private func loginWithAlby() {
        // TODO: handle the failed try
        
        let primaryBackground = UIColor(Color.primaryBackground)
        let color = colorScheme == .light ? lightThemeColor.color : darkThemeColor.color
        let tintColor = UIColor(color)
        
        guard let safariVC = try? alby.oauthService.authenticateWithSwiftUI(
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
