//
//  NewGroupSetupScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 07.06.24.
//

import SwiftUI

struct NewGroupSetupScreen: View {
    
    @State private var channelName = ""
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    var onCreate: (_ newChannel: ChannelItem) -> Void
    
    var body: some View {
        List {
            Section {
                channelSetupHeaderView()
            }
            
            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }
            
            Section {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleItemSelection(user)
                }
            } header: {
                let count = viewModel.selectedChatPartners.count
                let maxCount = ChannelConstants.maxGroupParticipants
                
                Text("Participants: \(count) of \(maxCount)")
                    .bold()
            }
            .listRowBackground(Color.clear)
           
          
        }
        .navigationTitle("New Group")
        .toolbar {
            trailingNavItem()
        }
        
    }
    
    private func channelSetupHeaderView() -> some View {
        HStack {
            profileImageView()
            
            TextField("", text: $channelName,
                      prompt: Text("Group Name (optional)"),
                      axis: .vertical
            )
        }
    }
    
    private func profileImageView() -> some View {
        Button {
            
        } label: {
            ZStack {
                Image(systemName: "camera.fill")
                    .imageScale(.large)
            }
            .frame(width: 60, height: 60)
            .background(Color(.systemGray6))
            .clipShape(.circle)
        }
    }
}

extension NewGroupSetupScreen {
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                if viewModel.isDirectChannel {
                    guard let chatPartner = viewModel.selectedChatPartners.first else { return }
                    viewModel.createDirectChannel(chatPartner, completion: onCreate)
                } else {
                    viewModel.createGroupChannel(channelName, completion: onCreate)
                }
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        NewGroupSetupScreen(viewModel: ChatPartnerPickerViewModel()) { _ in
            
        }
    }
}
