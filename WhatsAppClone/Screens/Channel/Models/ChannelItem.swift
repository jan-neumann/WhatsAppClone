//
//  ChannelItem.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 13.06.24.
//

import Foundation
import Firebase

struct ChannelItem: Identifiable, Hashable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimeStamp: Date
    var membersCount: Int
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    private var thumbnailUrl: String?
    let createdBy: String
    
    var coverImageUrl: String? {
        if let thumbnailUrl = thumbnailUrl {
            return thumbnailUrl
        }
        
        if !isGroupChat {
            return membersExcludingMe.first?.profileImageUrl
        }
        
        return nil
    }
    var isGroupChat: Bool {
        membersUids.count > 2
    }
    
    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter({ $0.uid != currentUid })
    }
     
    var title: String {
        if let name = name {
            return name
        }
        
        if isGroupChat {
            return groupMembersNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }
    
    var isCreatedByMe: Bool {
        createdBy == Auth.auth().currentUser?.uid ?? ""
    }
    
    var creatorName: String {
        return members.first { $0.uid == createdBy}?.username ?? "Someone"
    }
    
    private var groupMembersNames: String {
        let membersCount = membersCount - 1 
        let fullNames: [String] = membersExcludingMe.map { $0.username }
        
        if membersCount == 2 {
            return fullNames.joined(separator: " and ")
        } else if membersCount > 2 {
            let remainingCount = membersCount - 2
            return fullNames.prefix(2).joined(separator: ", ") + ", and \(remainingCount) " + "others"
        }
        
        return "Unknown"
    }
    
    static let placeholder = ChannelItem(
        id: "1",
        lastMessage: "Hello world",
        creationDate: .now,
        lastMessageTimeStamp: .now,
        membersCount: 2,
        adminUids: [],
        membersUids: [],
        members: [], 
        createdBy: ""
    )
}

extension ChannelItem {
    
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String? ?? nil
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let creationInterval = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        let lastMsgTimeStampInterval = dict[.lastMessageTimeStamp] as? Double ?? 0
        self.lastMessageTimeStamp = Date(timeIntervalSince1970: lastMsgTimeStampInterval)
        self.membersCount = dict[.membersCount] as? Int ?? 0
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.membersUids = dict[.membersUids] as? [String] ?? []
        self.members = dict[.members] as? [UserItem] ?? []
        self.createdBy = dict[.createdBy] as? String ?? ""
    }

}

extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimeStamp = "lastMessageTimeStamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let membersUids = "membersUids"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
    static let createdBy = "createdBy"
}
