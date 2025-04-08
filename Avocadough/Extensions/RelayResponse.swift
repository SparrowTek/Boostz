//
//  RelayResponse.swift
//  Avocadough
//
//  Created by Thomas Rademaker on 1/8/25.
//
/*
import NostrSDK

extension RelayResponse: @retroactive Equatable {}
extension RelayResponse: @retroactive Hashable {
    public static func == (lhs: RelayResponse, rhs: RelayResponse) -> Bool {
        switch (lhs, rhs) {
        case let (.event(id1, event1), .event(id2, event2)):
            return id1 == id2 && event1 == event2
        case let (.ok(id1, success1, message1), .ok(id2, success2, message2)):
            return id1 == id2 && success1 == success2 && message1.prefix == message2.prefix && message1.message == message2.message
        case let (.eose(id1), .eose(id2)):
            return id1 == id2
        case let (.closed(id1, message1), .closed(id2, message2)):
            return id1 == id2 && message1.prefix == message2.prefix && message1.message == message2.message
        case let (.notice(message1), .notice(message2)):
            return message1 == message2
        case let (.auth(challenge1), .auth(challenge2)):
            return challenge1 == challenge2
        case let (.count(id1, count1), .count(id2, count2)):
            return id1 == id2 && count1 == count2
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .event(subscriptionId, event):
            hasher.combine(0)
            hasher.combine(subscriptionId)
            hasher.combine(event)
        case let .ok(eventId, success, message):
            hasher.combine(1)
            hasher.combine(eventId)
            hasher.combine(success)
            hasher.combine(message.prefix)
            hasher.combine(message.message)
        case let .eose(subscriptionId):
            hasher.combine(2)
            hasher.combine(subscriptionId)
        case let .closed(subscriptionId, message):
            hasher.combine(3)
            hasher.combine(subscriptionId)
            hasher.combine(message.prefix)
            hasher.combine(message.message)
        case let .notice(message):
            hasher.combine(4)
            hasher.combine(message)
        case let .auth(challenge):
            hasher.combine(5)
            hasher.combine(challenge)
        case let .count(subscriptionId, count):
            hasher.combine(6)
            hasher.combine(subscriptionId)
            hasher.combine(count)
        }
    }
}
*/
