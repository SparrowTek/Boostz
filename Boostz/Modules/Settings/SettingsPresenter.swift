//
//  SettingsPresenter.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI

@MainActor
struct SettingsPresenter: View {
    @Environment(SettingsState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            SettingsView()
                .confirmationDialog("logout?", isPresented: $state.presentLogoutDialog) {
                    Button("logout", role: .destructive, action: logout)
                    Button("cancel", role: .cancel, action: {})
                }
                .navigationDestination(for: SettingsState.NavigationLink.self) {
                    switch $0 {
                    case .privacy:
                        Text("privacy policy")
                            .interactiveDismissDisabled()
                    case .about:
                        Text("about")
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

@MainActor
struct SettingsView: View {
    @Environment(SettingsState.self) private var state
    @Environment(\.dismiss) private var dismiss
    
    // MARK: color scheme properties
    @State private var selectedColorScheme = 0
    @AppStorage(Build.Constants.UserDefault.colorScheme) private var colorSchemeString: String?
    
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
            
//            Section {
//                NavigationLink(value: SettingsState.NavigationLink.theme) {
//                    Label("theme", systemImage: "line.3.crossed.swirl.circle.fill")
//                }
//            }
            
            Section("color scheme") {
                Picker("selected color scheme", selection: $selectedColorScheme) {
                    Text("system").tag(0)
                    Text("light").tag(1)
                    Text("dark").tag(2)
                }
                .pickerStyle(.segmented)
            }
            
            Button("logout and clear all data", systemImage: "bolt.trianglebadge.exclamationmark.fill", role: .destructive, action: logoutAlert)
                .foregroundStyle(.red)
        }
        .commonView()
        .navigationTitle("settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
        
        // MARK: color scheme modifiers
        .onAppear(perform: setSelectedColorScheme)
        .onChange(of: selectedColorScheme, updateColorScheme)
    }
    
    private func logoutAlert() {
        state.presentLogoutDialog = true
    }
    
    // MARK: Color scheme methods
    private func setSelectedColorScheme() {
        switch colorSchemeString {
        case Build.Constants.Theme.light: selectedColorScheme = 1
        case Build.Constants.Theme.dark: selectedColorScheme = 2
        default: selectedColorScheme = 0
        }
    }
    
    private func updateColorScheme() {
        switch selectedColorScheme {
        case 1: colorSchemeString = Build.Constants.Theme.light
        case 2: colorSchemeString = Build.Constants.Theme.dark
        default: colorSchemeString = nil
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
