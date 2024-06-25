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
    let type: MessageType
    let direction: MessageDirection
    
    
    static let sentPlaceHolder = MessageItem(text: "Holy Spaghetti", type: .text, direction: .sent)
    static let receivedPlaceHolder = MessageItem(text: "May the force be with you!", type: .text, direction: .received)
    
    var alignment: Alignment {
        direction == .received ? .leading : .trailing
    }
    
    var horizontalAlignment: HorizontalAlignment {
        direction == .received ? .leading : .trailing
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    static let stubMessages: [MessageItem] = [
        .init(text: "Hi there", type: .text, direction: .sent),
        .init(text: "Check out this photo", type: .photo, direction: .received),
        .init(text: "Play this video", type: .video, direction: .sent),
        .init(text: "Listen to this audio", type: .audio, direction: .received)
    ]
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
}
