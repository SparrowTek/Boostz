//
//  OnOpenURL.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 1/6/24.
//

import SwiftUI

fileprivate struct OnOpenURL: ViewModifier {
    @Environment(AppState.self) private var state
    @State private var url: URL?
    @State private var onOpenURLTrigger = PlainTaskTrigger()
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url = $0 }
            .onChange(of: url, triggerOnOpenUrl)
            .task($onOpenURLTrigger) { await openUrl() }
    }
    
    private func triggerOnOpenUrl() {
        onOpenURLTrigger.trigger()
    }
    
    private func openUrl() async {
        guard let url else { return }
        await state.onOpenURL(url)
    }
}

extension View {
    func onOpenURL() -> some View {
        modifier(OnOpenURL())
    }
}
