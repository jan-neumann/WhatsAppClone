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
    
    init(channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setupVoiceRecorderListeners()
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
                    self.getMessages()
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
        guard let currentUser else { return }
        if mediaAttachments.isEmpty {
            MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
                self?.textMessage = ""
            }
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
        }
    }
    
    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        mediaAttachments.forEach { attachment in
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: text, attachment)
            case .video:
                sendVideoMessage(text: text, attachment)
            case .audio:
                sendAudioMessage(text: text, attachment)
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
            
            MessageService.sendMediaMessage(to: channel, params: uploadParams) {
                // TODO: Scroll to bottom upon image upload success
                print("Uploaded photo to database")
            }
        }

       
        
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
    
    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        
    }
    
    private func sendAudioMessage(text: String, _ attachment: MediaAttachment) {
        
    }
    
    private func getMessages() {
        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            print("messages: \(messages.map{ $0.text })")
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
            self.getMessages()
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
}
