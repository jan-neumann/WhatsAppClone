//
//  AuthButton.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 29.05.24.
//

import SwiftUI

struct AuthButton: View {
    
    let title: String
    let onTap: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    
    private var backgroundColor: Color {
        isEnabled ? Color.white : Color.white.opacity(0.3)
    }  
    
    private var textColor: Color {
        isEnabled ? Color.green : Color.white
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text(title)
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: 10, style: .continuous))
            .shadow(color: .green.opacity(0.2), radius: 10)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        AuthButton(title: "Login") {
            
        }
    }
    .ignoresSafeArea()
}
