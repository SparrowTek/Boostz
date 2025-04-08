//
//  setupAlby.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 5/7/24.
//

//import SwiftUI
//
//fileprivate struct SetupAlbyKit: ViewModifier {
//    @Environment(AppState.self) private var state
//    
//    func body(content: Content) -> some View {
//        content
//            .task { await setupAlbyKit() }
//    }
//    
//    private func setupAlbyKit() async {
//        guard let infoDictionary = Bundle.main.infoDictionary,
//              let clientID = infoDictionary["AlbyClientID"] as? String,
//              let clientSecret = infoDictionary["AlbyClientSecret"] as? String else { fatalError("AlbyKit clientID, clientSecret, and oauth redirectURI are not properly set in your User.xcconfig file") }
//        await AlbyKit.setup(api: Build.shared.environment.alby, clientID: clientID, clientSecret: clientSecret, redirectURI: "avocadough://alby")
//        await state.setAlbyDelegate()
//    }
//}
//
//extension View {
//    func setupAlbyKit() -> some View {
//        modifier(SetupAlbyKit())
//    }
//}
//
//#Preview {
//    Text("Setup Alby Kit")
//        .setupAlbyKit()
//        .environment(AppState())
//}
