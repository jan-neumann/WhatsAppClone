//
//  AuthHeaderView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 29.05.24.
//

import SwiftUI

struct AuthHeaderView: View {
    var body: some View {
        HStack {
            Image(.whatsapp)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("WhatsUp")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
            
        }
    }
}

#Preview {
    AuthHeaderView()
}
