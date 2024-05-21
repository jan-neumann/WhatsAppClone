//
//  SettingsItemView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 21.05.24.
//

import SwiftUI

struct SettingsItemView: View {
    
    let item: SettingsItem
    
    var body: some View {
        HStack {
            iconImageView()
                .frame(width: 30, height: 30)
                .background(item.backgroundColor)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 5, style: .continuous))
            
            Text(item.title)
                .font(.system(size: 18))
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func iconImageView() -> some View {
        switch item.imageType {
        case .systemImage:
            Image(systemName: item.imageName)
                .font(.callout)
                .bold()
            
        case .assetImage:
            Image(item.imageName)
                .renderingMode(.template)
                .padding(3)
        }
    }
}

#Preview {
    SettingsItemView(item: .avatar)
}
