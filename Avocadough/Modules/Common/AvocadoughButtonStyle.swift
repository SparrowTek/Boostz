//
//  AvocadoughButtonStyle.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI

struct AvocadoughButton: ButtonStyle {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @Environment(\.colorScheme) private var colorScheme
    
    private var color: Color {
        colorScheme == .light ? lightThemeColor.color : darkThemeColor.color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .border(color)
            .font(.headline)
            .foregroundStyle(color)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == AvocadoughButton {
    static var avocadough: Self { .init() }
}

#Preview {
    Button("Avocadough", action: { })
        .buttonStyle(.avocadough)
}
