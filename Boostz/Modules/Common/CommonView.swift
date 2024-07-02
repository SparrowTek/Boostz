//
//  CommonView.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/10/23.
//

import SwiftUI

fileprivate struct CommonView: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func commonView() -> some View {
        modifier(CommonView())
    }
}

#Preview {
    Text("common view")
        .commonView()
        .foregroundStyle(.black)
}
