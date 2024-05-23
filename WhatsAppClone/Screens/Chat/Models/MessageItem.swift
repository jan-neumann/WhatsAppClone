//
//  MessageItem.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 23.05.24.
//

import SwiftUI

struct MessageItem: Identifiable {
    let id = UUID().uuidString
    let text: String
    let direction: MessageDirection
    
    static let sentPlaceHolder = MessageItem(text: "Holy Spaghetti", direction: .sent)
    static let receivedPlaceHolder = MessageItem(text: "May the force be with you!", direction: .received)
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, MessageDirection.received].randomElement() ?? .sent
    }
}
