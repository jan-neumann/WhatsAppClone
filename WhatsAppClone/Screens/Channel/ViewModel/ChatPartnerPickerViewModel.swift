//
//  ChatPartnerPickerViewModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 05.06.24.
//

import Foundation

enum ChannelCreationRoute {
    case addGroupChatMembers
    case setUpGroupChat
}

final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
}
