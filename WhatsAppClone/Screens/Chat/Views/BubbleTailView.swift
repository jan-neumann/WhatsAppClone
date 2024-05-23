//
//  BubbleTailView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 23.05.24.
//

import SwiftUI

struct BubbleTailView: View {
    let direction: MessageDirection
    
    private var backgroundColor: Color {
        direction == .received ? .bubbleWhite : .bubbleGreen
    }
    
    var body: some View {
        Image(direction == .received ? .incomingTail : .outgoingTail)
            .renderingMode(.template)
            .resizable()
            .frame(width: 10, height: 10)
            .offset(y: 3)
            .foregroundStyle(backgroundColor)
    }
}

#Preview {
    ScrollView {
        BubbleTailView(direction: .sent)
        BubbleTailView(direction: .received)
    }
    .frame(maxWidth: .infinity)
    .background(.gray)
}
