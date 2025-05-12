//
//  AvocadoughModel.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/28/24.
//

import SwiftUI
import SwiftData

struct AvocadoughDataContainerViewModifier: ViewModifier {
    let container: ModelContainer
    let schema = Schema([
        NWCConnection.self,
        Transaction.self,
        Wallet.self,
    ])
    
    init(inMemory: Bool) {
        do {
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Failed to create ModelContainer")
        }
    }
    
    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

class AvocadoughModelOptions {
//    #if DEBUG
//    public static let inMemoryPersistence = true
//    #else
//    public static let inMemoryPersistence = false
//    #endif
    
    static let inMemoryPersistence = false
}


extension View {
    func setupModel(inMemory: Bool = AvocadoughModelOptions.inMemoryPersistence) -> some View {
        modifier(AvocadoughDataContainerViewModifier(inMemory: inMemory))
    }
}

