//
//  BubbleTextView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 23.05.24.
//

import SwiftUI

struct BubbleTextView: View {
    
    let item: MessageItem
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.showGroupPartnerInfo {
                CircularProfileImageView(
                    profileImageUrl: item.sender?.profileImageUrl,
                    size: .mini
                )
            }
            
            if item.direction == .sent {
                timeStampTextView()
            }
            
            Text(item.text)
                .padding()
                .background(item.backgroundColor)
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
                .applyTail(item.direction)
            
            if item.direction == .received {
                timeStampTextView()
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
    }
    
    private func timeStampTextView() -> some View {
        Text(item.timeStamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ScrollView {
        ForEach(0..<20) { _ in
            BubbleTextView(item: [MessageItem.sentPlaceHolder, MessageItem.receivedPlaceHolder].randomElement()!)
        }
    }
    .frame(maxWidth: .infinity)
    .background(.gray.opacity(0.4))
}
