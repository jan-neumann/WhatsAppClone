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
        VStack(alignment: item.horizontalAlignment, spacing: 3) {
            Text(item.text)
                .padding()
                .background(item.backgroundColor)
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
                .applyTail(item.direction)
            timeStampTextView()
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .sent ? 100 : 5)
        .padding(.trailing, item.direction == .sent ? 5 : 100)
    }
    
    private func timeStampTextView() -> some View {
        HStack {
            Text(item.timeStamp.formatToTime)
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(.systemBlue))
            }
        }
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
