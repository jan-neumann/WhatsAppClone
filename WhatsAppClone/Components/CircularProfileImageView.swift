//
//  CircularProfileImageView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 02.07.24.
//

import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    
    let profileImageUrl: String?
    let size: Size
    let fallbackImage: FallbackImage
    
    init(profileImageUrl: String? = nil, size: Size) {
        self.profileImageUrl = profileImageUrl
        self.size = size
        self.fallbackImage = .directChatIcon
    }
    
    var body: some View {
        if let profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(.circle)
        } else {
            placeholderImageView()
        }
    }
    
    private func placeholderImageView() -> some View {
        Image(systemName: fallbackImage.rawValue)
            .resizable()
            .scaledToFit()
            .imageScale(.large)
            .foregroundStyle(Color.placeholder)
            .frame(width: size.dimension, height: size.dimension)
            .background(.white)
            .clipShape(.circle)
    }
}

extension CircularProfileImageView {
    enum Size {
        case mini
        case xSmall
        case small
        case medium
        case large
        case xLarge
        case custom(CGFloat)
        
        var dimension: CGFloat {
            switch self {
            case .mini:
                30
            case .xSmall:
                40
            case .small:
                50
            case .medium:
                60
            case .large:
                80
            case .xLarge:
                120
            case .custom(let dim):
                dim
            }
        }
    }
    
    enum FallbackImage: String {
        case directChatIcon = "person.circle.fill"
        case groupChatIcon = "person.2.circle.fill"
        
        init(for membersCount: Int) {
            switch membersCount {
            case 2:
                self = .directChatIcon
            default:
                self = .groupChatIcon
            }
        }
    }
}

extension CircularProfileImageView {
    init(_ channel: ChannelItem, size: Size) {
        self.profileImageUrl = channel.coverImageUrl
        self.size = size
        self.fallbackImage = FallbackImage(for: channel.membersCount)
    }
}

#Preview {
    VStack {
        CircularProfileImageView(size: .mini)
        CircularProfileImageView(size: .xSmall)
        CircularProfileImageView(size: .small)
        CircularProfileImageView(size: .medium)
        CircularProfileImageView(size: .large)
        CircularProfileImageView(size: .xLarge)
        CircularProfileImageView(size: .custom(150))
    }
}
