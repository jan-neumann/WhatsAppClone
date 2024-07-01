//
//  ChannelCreationTextView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 01.07.24.
//

import SwiftUI

struct ChannelCreationTextView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .yellow
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            (
                Text(Image(systemName: "lock.fill"))
                +
                Text(" Messages and calls are end-to-end encrypted, No one outside of this chat, not even WhatsUp, can read or listen to them.")
                +
                Text(" Learn more.")
                    .bold()
            )
        }
        .font(.footnote)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(0.6))
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 30)
    }
}

#Preview {
    ChannelCreationTextView()
}
