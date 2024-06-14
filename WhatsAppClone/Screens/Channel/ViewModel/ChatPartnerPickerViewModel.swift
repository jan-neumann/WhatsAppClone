//
//  ChatPartnerPickerViewModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 05.06.24.
//

import Foundation
import Firebase

enum ChannelCreationRoute {
    case groupPartnerPicker
    case setUpGroupChat
}

enum ChannelConstants {
    static let maxGroupParticipants = 12
}

enum ChannelCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published private(set) var users = [UserItem]()
    
    private var lastCursor: String?
    
    var showSelectedUsers: Bool {
        return !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartners.isEmpty
    }
    
    var isPaginatable: Bool {
        !users.isEmpty
    }
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    
    // MARK: - Public Methods
    
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter({ $0.uid != currentUid })
            self.users.append(contentsOf:fetchedUsers)
            self.lastCursor = userNode.currentCursor
            print("💿 lastCursor: \(String(describing: lastCursor)) \(users.count)")
        } catch {
            print("💿 Failed to fetch users in ChatPartnerPickerViewModel")
        }
    }
    
    func handleItemSelection(_ item: UserItem) {
        if isUserSelected(item) {
            // deselect
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            // select
            selectedChatPartners.append(item)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartners.contains(where: { $0.uid == user.uid })
        return isSelected
    }
    
//    func buildDirectChannel() async -> Result<ChannelItem, Error> {
//        
//    }
    
    func createChannel(channelName: String?) -> Result<ChannelItem, Error> {
        
        guard !selectedChatPartners.isEmpty else {
            return .failure(ChannelCreationError.noChatPartner)
        }
        
        guard let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
              let currentUid = Auth.auth().currentUser?.uid
                //              let messageId = FirebaseConstants.MessagesRef.childByAutoId().key else {
        else {
            return .failure(ChannelCreationError.failedToCreateUniqueIds)
        }
        
        let timeStamp = Date().timeIntervalSince1970
        var membersUids = selectedChatPartners.compactMap({ $0.uid })
        membersUids.append(currentUid)
        
        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessage: "",
            .creationDate: timeStamp,
            .lastMessageTimeStamp: timeStamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid]
        ]
        
        if let channelName = channelName, !channelName.isEmptyOrWhitespace {
            channelDict[.name] = channelName
        }
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        
        membersUids.forEach { userId in
            /// keeping an index of the channel that a specific user belongs to
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
            /// make sure that a direct channel is unique
            FirebaseConstants.UserDirectChannels.child(userId).child(channelId).setValue(true)
        }
        
        let newChannelItem = ChannelItem(channelDict)
        return .success(newChannelItem)
    }
    
}
