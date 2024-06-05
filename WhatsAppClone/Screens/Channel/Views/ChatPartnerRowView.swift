//
//  ChatPartnerRowView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 05.06.24.
//

import SwiftUI

struct ChatPartnerRowView: View {
    
    let user: UserItem
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .foregroundStyle(.whatsAppBlack)
                
                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
                
            }
            
//            checkmark()
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeHolder)
}
