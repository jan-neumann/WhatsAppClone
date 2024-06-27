//
//  ChatRoomScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 22.05.24.
//

import SwiftUI

struct ChatRoomScreen: View {
    
    let channel: ChannelItem
    
    @StateObject var viewModel: ChatRoomViewModel
    
    init(channel: ChannelItem) {
        self.channel = channel
        self._viewModel =  StateObject(
            wrappedValue: ChatRoomViewModel(
                channel: channel
            )
        )
    }
    
    var body: some View {
        MessageListView(viewModel: viewModel)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                leadingNavItems()
                trailingNavItems()
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                TextInputArea(textMessage: $viewModel.textMessage) {
                    viewModel.sendMessage()
                }
            }
    }
}

// MARK: - Toolbar Items

extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Circle()
                    .frame(width: 35, height: 30)
                
                Text(channel.title)
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItems() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "video")
            }
            Button {
                
            } label: {
                Image(systemName: "phone")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen(channel: .placeholder)
    }
}
