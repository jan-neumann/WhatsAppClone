//
//  ChatRoomViewModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 20.06.24.
//

import SwiftUI
import Combine
import PhotosUI

@MainActor
final class ChatRoomViewModel: ObservableObject {
    
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    @Published var isRecordingVoiceMessage: Bool = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)
    @Published var isPaginating: Bool = false
    private var currentPage: String?
    private var firstMessage: MessageItem?
    
    private(set) var channel: ChannelItem
    private var currentUser: UserItem?
    private var subscriptions = Set<AnyCancellable>()
    private let voiceRecorderService = VoiceRecorderService()
    
    var showPhotoPickerPreview: Bool {
        return !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
    }
    
    var disableSendButton: Bool {
        return mediaAttachments.isEmpty && textMessage.isEmptyOrWhitespace
    }
    
    private var isPreviewMode: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    init(channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setupVoiceRecorderListeners()
        
        if isPreviewMode {
            messages = MessageItem.stubMessages
        }
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        voiceRecorderService.tearDown()
    }
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            guard let self = self else { return }
            switch authState {
            case .loggedIn(let currentUser):
                self.currentUser = currentUser
                if self.channel.allMembersFetched {
                    self.getHistoricalMessages()
                    print("channel members: \(channel.members.map({ $0.username }))")
                } else {
                    self.getAllChannelMembers()
                }
            default:
                break
            }
        }
        .store(in: &subscriptions)
    }
    
    private func setupVoiceRecorderListeners() {
        voiceRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecordingVoiceMessage = isRecording
            }
            .store(in: &subscriptions)
        
        voiceRecorderService.$elapsedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elapsedTime in
                self?.elapsedVoiceMessageTime = elapsedTime
            }
            .store(in: &subscriptions)
    }
    
    func sendMessage() {
        if mediaAttachments.isEmpty {
            sendTextMessage(textMessage)
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
            clearTextInputArea()
        }
    }
    
    private func sendTextMessage(_ text: String) {
        guard let currentUser else { return }
        MessageService.sendTextMessage(to: channel, from: currentUser, text) { [weak self] in
            self?.textMessage = ""
        }
    }
    
    private func clearTextInputArea() {
        textMessage = ""
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        UIApplication.dismissKeyboard()
    }
    
    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        for (index, attachment) in attachments.enumerated() {
            
            let textMessage = index == 0 ? text : ""
            
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: textMessage, attachment)
            case .video:
                sendVideoMessage(text: textMessage, attachment)
            case .audio:
                sendVoiceMessage(text: textMessage, attachment)
            }
        }
    }
    
    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        /// Upload the image to storage bucket
        uploadImageToStorage(attachment) { [weak self] imageUrl in
            /// Store the metadata to our database
            guard let self = self,
                  let user = currentUser
            else { return }
            print("Uploaded image to storage")
            let uploadParams = MessageUploadParams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailURL: imageUrl.absoluteString,
                sender: user
            )
            
            MessageService.sendMediaMessage(to: channel, params: uploadParams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
        }
        
    }
    
    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }
    
    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping(_ imageUrl: URL) -> Void) {
        FirebaseHelper.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case .success(let imageURL):
                completion(imageURL)
            case .failure(let error):
                print("Failed to upload Image to Storage: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("UPLOAD IMAGE PROGRESS: \(progress)")
        }
    }
    
    private func uploadFileToStorage(
        for uploadType: FirebaseHelper.UploadType,
        attachment: MediaAttachment,
        completion: @escaping(_ fileUrl: URL) -> Void) {
            
            guard let url = attachment.fileURL else { return }
            FirebaseHelper.uploadFile(for: uploadType, fileURL: url) { result in
                switch result {
                case .success(let fileUrl):
                    completion(fileUrl)
                case .failure(let error):
                    print("Failed to upload File to Storage: \(error.localizedDescription)")
                }
            } progressHandler: { progress in
                print("UPLOAD FILE PROGRESS: \(progress)")
            }
        }
    
    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        /// Uploads the video file to the storage bucket
        uploadFileToStorage(for: .videoMessage, attachment: attachment) { [weak self] videoURL in
            /// Upload the video thumbnail
            self?.uploadImageToStorage(attachment) { [weak self] thumbnailURL in
                guard let self, let currentUser else { return }
                let uploadParams = MessageUploadParams(
                    channel: self.channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    thumbnailURL: thumbnailURL.absoluteString,
                    videoURL: videoURL.absoluteString,
                    sender: currentUser
                )
                /// Saves the metadata and urls to the database
                MessageService.sendMediaMessage(
                    to: self.channel,
                    params: uploadParams) { [weak self] in
                        self?.scrollToBottom(isAnimated: true)
                    }
            }
        }
    }
    
    private func sendVoiceMessage(text: String, _ attachment: MediaAttachment) {
        /// Uploads the audio file to the storage bucket
        guard let audioDuration = attachment.audioDuration else { return }
        
        uploadFileToStorage(for: .voiceMessage, attachment: attachment) { [weak self] audioURL in
            guard let self, let currentUser else { return }
            let uploadParams = MessageUploadParams(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: currentUser,
                audioURL: audioURL.absoluteString,
                audioDuration: audioDuration
            )
            /// Saves the metadata and urls to the database
            MessageService.sendMediaMessage(
                to: self.channel,
                params: uploadParams) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                }
            
            guard !text.isEmptyOrWhitespace else { return }
            self.sendTextMessage(text)
        }
    }
    
    var isPaginatable: Bool {
        currentPage != firstMessage?.id
    }
    
    private func getHistoricalMessages() {
        isPaginating = currentPage != nil
        MessageService.getHistoricalMessages(for: channel, lastCursor: currentPage, pageSize: 5) { [weak self] messageNode in
            /// If It's the initial data pull
            if self?.currentPage == nil {
                self?.getFirstMessage()
                self?.listenForNewMessages()
            }
            self?.messages.insert(contentsOf: messageNode.messages, at: 0)
            self?.currentPage = messageNode.currentCursor
            self?.scrollToBottom(isAnimated: false)
            self?.isPaginating = false
            print("messages: \(messageNode.messages.map{ $0.text })")
        }
    }
    
    func paginateMoreMessages() {
        guard isPaginatable else {
            isPaginating = false
            return
        }
        getHistoricalMessages()
    }
    
    private func getFirstMessage() {
        MessageService.getFirstMessage(in: channel) { [weak self] firstMessage in
            self?.firstMessage = firstMessage
            print("getFirstMessage: \(firstMessage.id)")
        }
    }
    
    private func listenForNewMessages() {
        MessageService.listenForNewMessages(in: channel) { [weak self] newMessage in
            self?.messages.append(newMessage)
            print("newMessage: \(newMessage.id)")
            self?.scrollToBottom(isAnimated: false)
        }
    }
    
    private func getAllChannelMembers() {
        /// I already have the current user, and potentially 2 other members so no need to refetch those
        guard let currentUser = currentUser else { return }
        let membersAlreadyFetched = channel.members
            .compactMap { $0.uid }
        
        let memberUidsToFetch = channel.membersUids
            .filter { !membersAlreadyFetched.contains($0) }
            .filter { $0 != currentUser.uid }
        
        UserService.getUsers(with: memberUidsToFetch) { [weak self] userNode in
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getHistoricalMessages()
            print("getAllChannelMembers: \(channel.members.map({ $0.username }))")
        }
    }
    
    func handleTextInputArea(_ action: TextInputArea.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecorder()
        }
    }
    
    private func toggleAudioRecorder() {
        if voiceRecorderService.isRecording {
            // stop recording
            voiceRecorderService.stopRecording {[weak self] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            // start recording
            voiceRecorderService.startRecording()
        }
    }
    
    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, duration: audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    private func onPhotoPickerSelection() {
        $photoPickerItems
            .sink { [weak self] photoPickerItems in
                guard let self = self else { return }
                let audioRecordings = self.mediaAttachments.filter({ $0.type == .audio(.stubURL, duration: .stubTimeInterval) })
                self.mediaAttachments = audioRecordings
                Task { await self.parsePhotoPickerItems(photoPickerItems) }
            }
            .store(in: &subscriptions)
    }
    
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnailImage = try? await movie.url.generateVideoThumbnail(),
                   let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnailImage, movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try? await photoItem.loadTransferable(type: Data.self),
                    let thumbnail = UIImage(data: data),
                    let itemIdentifier = photoItem.itemIdentifier
                else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                self.mediaAttachments.insert(photoAttachment, at: 0)
            }
            
        }
    }
    
    func dismissMediaPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }
    
    func showMediaPlayer(_ fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }
    
    func handleMediaAttachmentPreview(_ action: MediaAttachmentPreview.UserAction) {
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        case .remove(let attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(fileURL, duration: .stubTimeInterval) {
                voiceRecorderService.deleteRecording(at: fileURL)
            }
        }
    }
    
    private func remove(_ item: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == item.id}) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        
        guard let photoIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == item.id}) else { return }
        photoPickerItems.remove(at: photoIndex)
    }
    
    func isNewDay(for message: MessageItem, at index: Int) -> Bool {
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        return !message.timeStamp.isSameDay(as: priorMessage.timeStamp)
    }
    
    func showSenderName(for message: MessageItem, at index: Int) -> Bool {
        guard channel.isGroupChat else { return false }
        
        /// Show only when it's a group chat and when it's not sent by current user
        let isNewDay = isNewDay(for: message, at: index)
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        
        if isNewDay {
            /// If it's not sent by current user && is a group chat
            return !message.isSentByCurrentUser
        } else {
            /// If it's not sent by current user && is a group chat && the message before this one is not sent by the same sender
            return !message.isSentByCurrentUser && !message.containsSameOwner(as: priorMessage)
        }
    }
    
    func addReaction(_ reaction: Reaction, to message: MessageItem) {
        guard let currentUser else { return }
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        
        MessageService.addReaction(reaction, to: message, in: channel, from: currentUser) { [weak self] emojiCount in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.messages[index].reactions[reaction.emoji] = emojiCount
                self?.messages[index].userReactions[currentUser.uid] = reaction.emoji
                print("reacted to message with \(reaction.emoji) count is \(emojiCount)")
            }
        }
    }
}
