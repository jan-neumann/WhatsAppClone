//
//  MessageItem+Types.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 18.06.24.
//

import Foundation

enum AdminMessageType: String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageType {
    case text, photo, video, audio
    
    var title: String {
        switch self {
        case .text:
            "text"
        case .photo:
            "photo"
        case .video:
            "video"
        case .audio:
            "audio"
        }
    }
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, MessageDirection.received].randomElement() ?? .sent
    }
}
