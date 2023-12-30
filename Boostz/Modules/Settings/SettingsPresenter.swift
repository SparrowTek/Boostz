//
//  SettingsPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI

struct SettingsPresenter: View {
    @Environment(SettingsState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            SettingsView()
                .navigationDestination(for: SettingsState.NavigationLink.self) {
                    switch $0 {
                    case .privacy:
                        Text("Privacy policy")
                            .interactiveDismissDisabled()
                    case .about:
                        Text("About")
                            .interactiveDismissDisabled()
                    case .albyInfo:
                        Text("ALBY INFO")
                            .interactiveDismissDisabled()
                    case .theme:
                        ThemeSettingsView()
                            .interactiveDismissDisabled()
                    }
                }
        }
        
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                NavigationLink(value: SettingsState.NavigationLink.albyInfo) {
                    Label("Alby", systemImage: "bolt.fill")
                }
                
                NavigationLink(value: SettingsState.NavigationLink.privacy) {
                    Label("privacy", systemImage: "hand.raised.fill")
                }
                
                NavigationLink(value: SettingsState.NavigationLink.about) {
                    Label("about", systemImage: "info")
                }
            }
            
            Section {
                NavigationLink(value: SettingsState.NavigationLink.theme) {
                    Label("theme", systemImage: "line.3.crossed.swirl.circle.fill")
                }
            }
        }
        .commonView()
        .navigationTitle("settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
}

#Preview {
    Text("BOOSTZ")
        .sheet(isPresented: .constant(true)) {
            SettingsPresenter()
                .environment(SettingsState(parentState: .init(parentState: .init())))
        }
}
