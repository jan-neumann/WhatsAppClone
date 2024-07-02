//
//  ChatPartnerRowView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 05.06.24.
//

import SwiftUI

struct ChatPartnerRowView<Content: View>: View {
    
    private let user: UserItem
    private let trailingItems: Content
    
    init(user: UserItem, @ViewBuilder trailingItems: () -> Content = { EmptyView() }) {
        self.user = user
        self.trailingItems = trailingItems()
    }
    
    var body: some View {
        HStack {
            CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .xSmall)
              
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .foregroundStyle(.whatsAppBlack)
                
                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            trailingItems
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeHolder) {
        Image(systemName: "xmark")
    }
}
