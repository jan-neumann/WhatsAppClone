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
                Text("Participants: \(viewModel.selectedChatPartners.count)/\(1)")
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
            Circle()
                .frame(width: 60, height: 60)
            
            TextField("", text: $channelName,
                      prompt: Text("Group Name (optional)"),
                      axis: .vertical
            )
        }
    }
}

extension NewGroupSetupScreen {
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        NewGroupSetupScreen(viewModel: ChatPartnerPickerViewModel())
    }
}
