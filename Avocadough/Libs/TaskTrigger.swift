//
//  TaskTrigger.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 12/30/23.
//

import SwiftUI

struct TaskTrigger<Value: Equatable>: Equatable where Value: Sendable {
    
    fileprivate enum TaskState<T: Equatable>: Equatable {
        case none
        case active(value: T, uuid: UUID? = nil)
    }
    
    /// Creates a new ``TaskTrigger/TaskTrigger``.
    init() {}
    
    fileprivate var state: TaskState<Value> = .none
    
    /// Triggers the tasks associated with this ``TaskTrigger/TaskTrigger`` and passes along a value of type `Value`.
    /// - Parameters:
    ///   - value: The value to pass along.
    ///   - id: (Optional) An UUID which by default is initialized each time this method gets called.
    ///   In a case a task should not be re-triggered, explicitly pass the same UUID.
    mutating func trigger(value: Value, id: UUID? = .init()) {
        self.state = .active(value: value, uuid: id)
    }
    
    /// Cancels the active task.
    mutating func cancel() {
        self.state = .none
    }
}

typealias PlainTaskTrigger = TaskTrigger<Bool>

extension PlainTaskTrigger {
    /// Triggers the tasks associated with this ``TaskTrigger/PlainTaskTrigger``.
    mutating func trigger() {
        self.state = .active(value: true)
    }
}

struct TaskTriggerViewModifier<Value: Equatable>: ViewModifier where Value: Sendable {
    
    typealias Action = @Sendable (_ value: Value) async -> Void
    
    fileprivate init(trigger: Binding<TaskTrigger<Value>>, action: @escaping Action) {
        self._trigger = trigger
        self.action = action
    }
    
    @Binding
    private var trigger: TaskTrigger<Value>
    
    private let action: Action
    
    func body(content: Content) -> some View {
        content
            .task(id: trigger.state) {
                // check that the trigger's state is indeed active and obtain the value.
                guard case let .active(value, _) = trigger.state else { return }
                
                // execute the async work.
                await action(value)
                
                // if not already cancelled, reset the trigger.
                if !Task.isCancelled {
                    self.trigger.cancel()
                }
            }
    }
}

extension View {
    /// Adds a task to perform whenever the specified trigger with an attached value fires.
    /// - Parameters:
    ///   - trigger: A binding to a ``TaskTrigger/TaskTrigger``.
    ///   - action: An async action to perform whenever the trigger fires. The attached value
    ///   is passed into the closure as an argument.
    func task<Value: Equatable>(_ trigger: Binding<TaskTrigger<Value>>, _ action: @escaping @Sendable @MainActor (_ value: Value) async -> Void) -> some View where Value: Sendable {
        modifier(TaskTriggerViewModifier(trigger: trigger, action: action))
    }
    
    /// Adds a task to perform whenever the specified trigger fires.
    /// - Parameters:
    ///   - trigger: A binding to a ``TaskTrigger/PlainTaskTrigger``.
    ///   - action: An async action to perform whenever the trigger fires.
    func task(_ trigger: Binding<PlainTaskTrigger>, _ action: @escaping @Sendable @MainActor () async -> Void) -> some View {
        modifier(TaskTriggerViewModifier(trigger: trigger, action: { _ in await action() }))
    }
}


