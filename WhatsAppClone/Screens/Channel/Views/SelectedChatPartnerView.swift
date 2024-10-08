//
//  SelectedChatPartnerView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 06.06.24.
//

import SwiftUI

struct SelectedChatPartnerView: View {
    
    let users: [UserItem]
    let onTapHandler: (_ user: UserItem) -> Void
    
    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(users) { item in
                    chatPartnerView(item)
                }
            }
        }
    }
    
    private func chatPartnerView(_ user: UserItem) -> some View {
        VStack {
            CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .medium)
                .overlay(alignment: .topTrailing) {
                    cancelButton(user)
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton(_ user: UserItem) -> some View {
        Button {
            onTapHandler(user)
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(5)
                .background(Color(.systemGray2))
                .clipShape(.circle)
        }
    }
}

#Preview {
    SelectedChatPartnerView(users: UserItem.placeHolders) { _ in
        
    }
}
