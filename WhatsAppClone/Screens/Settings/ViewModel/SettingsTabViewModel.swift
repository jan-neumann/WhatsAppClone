//
//  SettingsTabViewModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 14.10.24.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
import Firebase
import AlertKit

@MainActor
final class SettingsTabViewModel: ObservableObject {
    
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    @Published var showProgressHUD = false
    @Published var showSuccessHUD = false
    
    private(set) var progressHUDView = AlertAppleMusic17View(title: "Uploading Profile Photo", subtitle: nil, icon: .spinnerSmall)
    private(set) var successHUDView = AlertAppleMusic17View(title: "Profile Photo Uploaded", subtitle: nil, icon: .done)
    
    private var subscription: AnyCancellable?
    
    var disableSaveButton: Bool {
        return profilePhoto == nil
    }
    
    init() {
        onPhotoPickerSelection()
    }
    
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem = photoItem else { return }
                self?.parsePhotoPickerItem(photoItem)
            }
    }
    
    private func parsePhotoPickerItem(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(uiImage))
        }
    }
    
    func uploadProfilePhoto() {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        showProgressHUD = true
        FirebaseHelper.uploadImage(profilePhoto, for: .profilePhoto) { [weak self] result in
            switch result {
            case .success(let imageUrl):
                self?.onUploadSuccess(imageUrl)
            case .failure(let error):
                print("Failed to upload a profile image to firebase storage: \(error.localizedDescription)")
                
            }
        } progressHandler: { progress in
            print("Uploading image: progress: \(progress)")
        }
    }
    
    private func onUploadSuccess(_ imageUrl: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).child(.profileImageUrl).setValue(imageUrl.absoluteString)
        showProgressHUD = false
        progressHUDView.dismiss()
        /// Disable save button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showSuccessHUD = true
           
            self.profilePhoto = nil
            self.selectedPhotoItem = nil
        }
        print("onUploadSuccess: \(imageUrl.absoluteString)")
        
    }
}
