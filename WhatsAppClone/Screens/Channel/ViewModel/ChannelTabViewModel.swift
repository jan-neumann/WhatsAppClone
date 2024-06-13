//
//  ChannelTabViewModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 13.06.24.
//

import Foundation

final class ChannelTabViewModel: ObservableObject {
    @Published var navigateToChatRoom = false
    @Published var showChatPartnerPickerView = false
   
    @Published var newChannel: ChannelItem?
    
    func onNewChannelCreation(_ channel: ChannelItem) {
        showChatPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }
}
