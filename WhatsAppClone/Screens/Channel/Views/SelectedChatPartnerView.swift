//
//  SelectedChatPartnerView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 06.06.24.
//

import SwiftUI

struct SelectedChatPartnerView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(UserItem.placeHolders) { item in
                    chatPartnerView(item)
                }
            }
        }
    }
    
    private func chatPartnerView(_ user: UserItem) -> some View {
        VStack {
            Circle()
                .fill(.gray)
                .frame(width: 60, height: 60)
                .overlay(alignment: .topTrailing) {
                    cancelButton()
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            
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
    SelectedChatPartnerView()
}
