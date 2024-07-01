//
//  MessageItem.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 23.05.24.
//

import SwiftUI
import Firebase

struct MessageItem: Identifiable {
    
    let id: String
    let text: String
    let type: MessageType
    let ownerUid: String
    let timeStamp: Date
    
    var direction: MessageDirection {
        ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }
    
    
    static let sentPlaceHolder = MessageItem(id: UUID().uuidString, text: "Holy Spaghetti", type: .text, ownerUid: "1", timeStamp: .now)
    static let receivedPlaceHolder = MessageItem(id: UUID().uuidString, text: "May the force be with you!", type: .text, ownerUid: "2", timeStamp: .now)
    
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
        .init(id: UUID().uuidString, text: "Hi there", type: .text, ownerUid: "3", timeStamp: .now),
        .init(id: UUID().uuidString, text: "Check out this photo", type: .photo, ownerUid: "4", timeStamp: .now),
        .init(id: UUID().uuidString, text: "Play this video", type: .video, ownerUid: "5", timeStamp: .now),
        .init(id: UUID().uuidString, text: "Listen to this audio", type: .audio, ownerUid: "6", timeStamp: .now)
    ]
}

extension MessageItem {
    init(id: String, dict: [String: Any]) {
        self.id = id
        self.text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timeInterval = dict[.timeStamp] as? TimeInterval ?? 0
        self.timeStamp = Date(timeIntervalSince1970: timeInterval)
    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
}
