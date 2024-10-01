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
    let isGroupChat: Bool
    let text: String
    let type: MessageType
    let ownerUid: String
    let timeStamp: Date
    var sender: UserItem?
    let thumbnailURL: String?
    var thumbnailHeight: CGFloat?
    var thumbnailWidth: CGFloat?
    var videoURL: String?
    var audioURL: String?
    var audioDuration: TimeInterval?
    
    var direction: MessageDirection {
        ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }
    
    static let sentPlaceHolder = MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Holy Spaghetti", type: .text, ownerUid: "1", timeStamp: .now, thumbnailURL: nil)
    static let receivedPlaceHolder = MessageItem(id: UUID().uuidString, isGroupChat: false, text: "May the force be with you!", type: .text, ownerUid: "2", timeStamp: .now, thumbnailURL: nil)
    
    var alignment: Alignment {
        direction == .received ? .leading : .trailing
    }
    
    var horizontalAlignment: HorizontalAlignment {
        direction == .received ? .leading : .trailing
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    var showGroupPartnerInfo: Bool {
        return isGroupChat && direction == .received
    }
    
    var leadingPadding: CGFloat {
        return direction == .received ? 0 : horizontalPadding
    }
    
    var trailingPadding: CGFloat {
        return direction == .received ? horizontalPadding : 0
    }
    
    private let horizontalPadding: CGFloat = 25
    
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWidth)
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    private var imageWidth: CGFloat {
        (UIWindowScene.current?.screenWidth ?? 0) / 1.5
    }
    
    var audioDurationText: String {
        audioDuration?.formatElapsedTime ?? "00:00"
    }
    
    var isSentByCurrentUser: Bool {
        ownerUid == Auth.auth().currentUser?.uid ?? ""
    }
    
    func containsSameOwner(as message: MessageItem) -> Bool {
        if let userA = message.sender, let userB = self.sender {
            return userA.uid == userB.uid
        }
        return false
    }
    
    static let stubMessages: [MessageItem] = [
        .init(id: UUID().uuidString, isGroupChat: false, text: "Hi there", type: .text, ownerUid: "3", timeStamp: .now, thumbnailURL: nil),
        .init(id: UUID().uuidString, isGroupChat: true, text: "Check out this photo", type: .photo, ownerUid: "4", timeStamp: .now, thumbnailURL: nil),
        .init(id: UUID().uuidString, isGroupChat: false, text: "Play this video", type: .video, ownerUid: "5", timeStamp: .now, thumbnailURL: nil),
        .init(id: UUID().uuidString, isGroupChat: true, text: "Listen to this audio", type: .audio, ownerUid: "6", timeStamp: .now, thumbnailURL: nil)
    ]
}

extension MessageItem {
    init(id: String, isGroupChat: Bool, dict: [String: Any]) {
        self.id = id
        self.isGroupChat = isGroupChat
        self.text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timeInterval = dict[.timeStamp] as? TimeInterval ?? 0
        self.timeStamp = Date(timeIntervalSince1970: timeInterval)
        self.thumbnailURL = dict[.thumbnailUrl] as? String ?? nil
        self.thumbnailWidth = dict[.thumbnailWidth] as? CGFloat ?? nil
        self.thumbnailHeight = dict[.thumbnailHeight] as? CGFloat ?? nil
        self.videoURL = dict[.videoURL] as? String ?? nil
        self.audioURL = dict[.audioURL] as? String ?? nil
        self.audioDuration = dict[.audioDuration] as? TimeInterval ?? nil
    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoURL = "videoURL"
    static let audioURL = "audioURL"
    static let audioDuration = "audioDuration"
}
