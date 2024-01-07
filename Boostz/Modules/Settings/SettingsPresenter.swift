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
                .confirmationDialog("Logout?", isPresented: $state.presentLogoutDialog) {
                    Button("Logout", role: .destructive, action: logout)
                    Button("Cancel", role: .cancel, action: {})
                }
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
    
    private func logout() {
        state.logout()
    }
}

struct SettingsView: View {
    @Environment(SettingsState.self) private var state
    @Environment(\.dismiss) private var dismiss
    
    // TODO: add links to source code for app and albyKit
    // add link for value 4 value to support development
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
            
            Button("Logout and clear all data", systemImage: "bolt.trianglebadge.exclamationmark.fill", role: .destructive, action: logoutAlert)
                .foregroundStyle(.red)
        }
        .commonView()
        .navigationTitle("settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    private func logoutAlert() {
        state.presentLogoutDialog = true
    }
}

#Preview {
    Text("BOOSTZ")
        .sheet(isPresented: .constant(true)) {
            SettingsPresenter()
                .environment(SettingsState(parentState: .init(parentState: .init())))
        }
}
