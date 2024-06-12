//
//  GroupPartnerPickerScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 05.06.24.
//

import SwiftUI

struct GroupPartnerPickerScreen: View {
    
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        List {
            
            if viewModel.showSelectedUsers {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleItemSelection(user)
                }
            }
            
            Section {
                ForEach(viewModel.users) { user in
                    Button {
                        viewModel.handleItemSelection(user)
                    } label: {
                        chatPartnerRowView(user)
                    }
                }
            }
            
            if viewModel.isPaginatable {
                loadMoreUsersView()
            }
        }
        .animation(.easeInOut, value: viewModel.showSelectedUsers)
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search name or number"
        )
        .toolbar {
            titleView()
            trailingNavItem()
        }
    }
    
    private func chatPartnerRowView(_ user: UserItem) -> some View {
        ChatPartnerRowView(user: user) {
            Spacer()
            let isSelected = viewModel.isUserSelected(user)
            let imageName =  isSelected ? "checkmark.circle.fill" : "circle"
            let foregroundStyle = isSelected ? Color.blue : Color(.systemGray4)
            Image(systemName: imageName)
                .foregroundStyle(foregroundStyle)
                .imageScale(.large)
        }
    }
    
    private func loadMoreUsersView() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension GroupPartnerPickerScreen {
    @ToolbarContentBuilder
    private func titleView() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add Participants")
                    .bold()
                let count = viewModel.selectedChatPartners.count
                let maxcount = ChannelConstants.maxGroupParticipants
                Text("\(count)/\(maxcount)")
                    .foregroundStyle(.gray)
                    .font(.footnote)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Next") {
                viewModel.navStack.append(.setUpGroupChat)
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        GroupPartnerPickerScreen(viewModel: ChatPartnerPickerViewModel())
    }
}
