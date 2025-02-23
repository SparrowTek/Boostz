//
//  BoostzModel.swift
//  Boostz
//
//  Created by Thomas Rademaker on 12/28/24.
//

import SwiftUI
import SwiftData

struct BoostzDataContainerViewModifier: ViewModifier {
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

class BoostzModelOptions {
//    #if DEBUG
//    public static let inMemoryPersistence = true
//    #else
//    public static let inMemoryPersistence = false
//    #endif
    
    static let inMemoryPersistence = false
}


extension View {
    func setupModel(inMemory: Bool = BoostzModelOptions.inMemoryPersistence) -> some View {
        modifier(BoostzDataContainerViewModifier(inMemory: inMemory))
    }
}

