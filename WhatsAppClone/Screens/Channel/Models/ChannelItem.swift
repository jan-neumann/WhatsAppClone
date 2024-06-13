//
//  ChannelItem.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 13.06.24.
//

import Foundation

struct ChannelItem: Identifiable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimeStamp: Date
    var membersCount: UInt
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    var thumbnailUrl: String?
    
    var isGroupChat: Bool {
        members.count > 2
    }
    
    static let placeholder = ChannelItem(
        id: "1",
        lastMessage: "Hello world",
        creationDate: .now,
        lastMessageTimeStamp: .now,
        membersCount: 2,
        adminUids: [],
        membersUids: [],
        members: []
    )
}
