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
                Text("Users Selected")
            }
            
            Section {
                ForEach(UserItem.placeHolders) { item in
                    Button {
                        viewModel.handleItemSelection(item)
                    } label: {
                        chatPartnerRowView(item)
                    }
                }
                
            }
        }
        .animation(.easeInOut, value: viewModel.showSelectedUsers)
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search name or number"
        )
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
}

#Preview {
    NavigationStack {
        GroupPartnerPickerScreen(viewModel: ChatPartnerPickerViewModel())
    }
}
