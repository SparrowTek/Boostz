//
//  Alert.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 4/3/24.
//

import SwiftUI

extension View {
    func alert(_ errorMessage: Binding<LocalizedStringKey?>) -> some View {
        let binding = Binding(
            get: { errorMessage.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage.wrappedValue = nil
                }
            }
        )
        
        guard let errorMessage = errorMessage.wrappedValue else { return alert(Text(""), isPresented: binding, actions: { Button("OK") {} }) }
        return alert(Text(errorMessage), isPresented: binding, actions: { Button("OK") {} })
    }
}
