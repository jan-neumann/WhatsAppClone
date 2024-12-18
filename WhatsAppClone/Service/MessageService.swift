//
//  MessageService.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 25.06.24.
//

import Foundation
import Firebase
import FirebaseDatabaseSwift

// MARK: - Handles sending and fetching messages and setting reactions

struct MessageService {
    
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessage: String, onComplete: () -> Void) {
        let timeStamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessagesRef.childByAutoId().key else { return }
                
        let channelDict: [String: Any] = [
            .lastMessage: textMessage,
            .lastMessageTimeStamp: timeStamp,
            .lastMessageType: MessageType.text.title
        ]
        let messageDict: [String: Any] = [
            .text: textMessage,
            .type: MessageType.text.title,
            .timeStamp: timeStamp,
            .ownerUid: currentUser.uid
        ]
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessagesRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    static func sendMediaMessage(to channel: ChannelItem, params: MessageUploadParams, completion: @escaping () -> Void) {
        guard let messageId = FirebaseConstants.MessagesRef.childByAutoId().key else { return }
        let timeStamp = Date().timeIntervalSince1970
        
        let channelDict: [String: Any] = [
            .lastMessage: params.text,
            .lastMessageTimeStamp: timeStamp,
            .lastMessageType: params.type.title
        ]
        
        var messageDict: [String: Any] = [
            .text : params.text,
            .type: params.type.title,
            .timeStamp: timeStamp,
            .ownerUid: params.ownerUID,
            ]
        
        /// Photo Messages and Video Messages
        messageDict[.thumbnailUrl] = params.thumbnailURL ?? nil
        messageDict[.thumbnailWidth] = params.thumbnailWidth ?? nil
        messageDict[.thumbnailHeight] = params.thumbnailHeight ?? nil
        messageDict[.videoURL] = params.videoURL ?? nil
        
        /// Voice Messages
        messageDict[.audioURL] = params.audioURL ?? nil
        messageDict[.audioDuration] = params.audioDuration ?? nil
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessagesRef.child(channel.id).child(messageId).setValue(messageDict)
        
        completion()
    }
    
    static func getMessages(for channel: ChannelItem, completion: @escaping([MessageItem]) -> Void) {
        FirebaseConstants.MessagesRef.child(channel.id)
            .observe(.value) { snapshot in
                guard let dict = snapshot.value as? [String: Any] else { return }
                var messages: [MessageItem] = []
                dict.forEach { key, value in
                    let messageDict = value as? [String: Any] ?? [:]
                    var message = MessageItem(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                    let messageSender = channel.members.first(where: { $0.uid == message.ownerUid })
                    message.sender = messageSender
                    messages.append(message)
                    completion(messages)
                    if messages.count == snapshot.childrenCount {
                        messages.sort(by: { $0.timeStamp < $1.timeStamp })
                        completion(messages)
                    }
                }
            } withCancel: { error in
                print("Failed to get messages for \(channel.title)")
            }
    }
    
    static func getHistoricalMessages(
        for channel: ChannelItem,
        lastCursor: String?,
        pageSize: UInt,
        completion: @escaping (MessageNode) -> Void) {
            let query: DatabaseQuery
            
            if lastCursor == nil {
                query = FirebaseConstants.MessagesRef.child(channel.id)
                                .queryLimited(toLast: pageSize)
            } else {
                query = FirebaseConstants.MessagesRef.child(channel.id)
                    .queryOrderedByKey()
                    .queryEnding(atValue: lastCursor)
                    .queryLimited(toLast: pageSize)
            }
            
            query.observeSingleEvent(of: .value) { mainSnapshot in
                
                guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot]
                else { return }
                
                var messages: [MessageItem] = allObjects.compactMap { messageSnapshot in
                    let messageDict = messageSnapshot.value as? [String: Any] ?? [:]
                    var message = MessageItem(id: messageSnapshot.key, isGroupChat: channel.isGroupChat, dict: messageDict)
                    let messageSender = channel.members.first(where: { $0.id == message.ownerUid } )
                    message.sender = messageSender
                    return message
                }
                
                messages.sort { $0.timeStamp < $1.timeStamp }
                
                if messages.count == mainSnapshot.childrenCount {
                    if lastCursor == nil {
                        messages.removeLast()
                    }
                    let filteredMessages = lastCursor == nil ? messages : messages.filter { $0.id != lastCursor }
                    let messageNode = MessageNode(messages: filteredMessages, currentCursor: first.key)
                    completion(messageNode)
                }
                
            } withCancel: { error in
                completion(.emptyNode)
                print("Failed to get messages for channel: \(String(describing: channel.name))")
            }
    }
    
    static func getFirstMessage(in channel: ChannelItem, completion: @escaping (MessageItem) -> Void) {
        FirebaseConstants.MessagesRef.child(channel.id)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                dictionary.forEach { key, value in
                    guard let messageDict = snapshot.value as? [String: Any] else { return }
                    var firstMessage = MessageItem(id: key, isGroupChat: channel.isGroupChat, dict: messageDict)
                    let messageSender = channel.members.first(where: { $0.id == firstMessage.ownerUid } )
                    firstMessage.sender = messageSender
                    completion(firstMessage)
                }
            } withCancel: { error in
                print("Failed to get first message for channel: \(String(describing: channel.name)), error: \(error.localizedDescription)")
            }
    }
    
    static func listenForNewMessages(in channel: ChannelItem, completion: @escaping (MessageItem) -> Void) {
        FirebaseConstants.MessagesRef.child(channel.id)
            .queryLimited(toLast: 1)
            .observe(.childAdded) { snapshot in
                guard let messageDict = snapshot.value as? [String: Any] else { return }
                var newMessage = MessageItem(id: snapshot.key, isGroupChat: channel.isGroupChat, dict: messageDict)
                let messageSender = channel.members.first(where: { $0.id == newMessage.ownerUid } )
                newMessage.sender = messageSender
                completion(newMessage)
            }
    }
    
    static func addReaction(_ reaction: Reaction,
                            to message: MessageItem,
                            in channel: ChannelItem,
                            from currentUser: UserItem,
                            completion: @escaping(_ emojiCount: Int) -> Void)  {
        // Increment emoji reactions count
        let reactionsRef = FirebaseConstants.MessagesRef
            .child(channel.id)
            .child(message.id)
            .child(.reactions)
            .child(reaction.emoji)
        
        increaseCountViaTransaction(at: reactionsRef) { emojiCount in
            // add current user emoji to userReactions node
            FirebaseConstants.MessagesRef
                .child(channel.id)
                .child(message.id)
                .child(.userReactions)
                .child(currentUser.uid)
                .setValue(reaction.emoji)
            
            completion(emojiCount)
        }
    }
    
    static func increaseCountViaTransaction(at ref: DatabaseReference, completion: ((Int) -> Void)? = nil) {
        ref.runTransactionBlock { currentData in
            if var count = currentData.value as? Int {
                count += 1
                currentData.value = count
            } else {
                currentData.value = 1
            }
            completion?(currentData.value as? Int ?? 0)
            return TransactionResult.success(withValue: currentData)
        }
    }
    
}

struct MessageNode {
    var messages: [MessageItem]
    var currentCursor: String?
    static let emptyNode = MessageNode(messages: [], currentCursor: nil)
    
}

struct MessageUploadParams {
    let channel: ChannelItem
    let text: String
    let type: MessageType
    let attachment: MediaAttachment
    var thumbnailURL: String?
    var videoURL: String?
    var sender: UserItem
    var audioURL: String?
    var audioDuration: TimeInterval?
    
    var ownerUID: String {
        sender.uid
    }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.height
    }
    
}
