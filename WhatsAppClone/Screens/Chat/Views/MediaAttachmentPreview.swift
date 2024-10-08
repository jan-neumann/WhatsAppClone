//
//  MediaAttachmentPreview.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 03.09.24.
//

import SwiftUI

struct MediaAttachmentPreview: View {
    
    let mediaAttachments: [MediaAttachment]
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(mediaAttachments) { attachment in
                    if attachment.type == .audio(.stubURL, duration: .stubTimeInterval) {
                        audioAttachmentPreview(attachment)
                    } else {
                        thumbnailImageView(attachment)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: Constants.listHeight)
        .frame(maxWidth: .infinity)
        .background(.whatsAppWhite)
        
    }
    
    private func thumbnailImageView(_ attachment: MediaAttachment) -> some View {
        Button {
            
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.imageDim, height: Constants.imageDim)
                .clipShape(.rect(cornerRadius: 5))
                .overlay(alignment: .topTrailing) {
                    cancelButton(attachment)
                }
                .overlay {
                    playButton("play.fill", attachment: attachment)
                    .opacity(
                        attachment.type == .video(UIImage(), .stubURL) ? 1 : 0
                    )
                }
        }
    }
    
    private func cancelButton(_ attachment: MediaAttachment) -> some View {
        Button {
            actionHandler(.remove(attachment))
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .padding(5)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(.circle)
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func playButton(_ systemName: String, attachment: MediaAttachment) -> some View {
        Button {
            actionHandler(.play(attachment))
        } label: {
            Image(systemName: systemName)
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
                .clipShape(.circle)
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func audioAttachmentPreview(_ attachment: MediaAttachment) -> some View {
        ZStack {
            LinearGradient(colors: [.green, .green.opacity(0.8), .teal],
                           startPoint: .topLeading,
                           endPoint: .bottom
            )
            playButton("mic.fill", attachment: attachment)
                .padding(.bottom, 15)
        }
        .frame(width: Constants.imageDim * 2, height: Constants.imageDim)
        .clipShape(.rect(cornerRadius: 5))
        .overlay(alignment: .topTrailing) {
            cancelButton(attachment)
        }
        .overlay(alignment: .bottomLeading) {
            Text(attachment.fileURL?.absoluteString ?? "Unknown")
                .lineLimit(1)
                .font(.caption)
                .padding(2)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .background(.white.opacity(0.5))
        }
    }
}

extension MediaAttachmentPreview {
    enum Constants {
        static let listHeight: CGFloat = 100
        static let imageDim: CGFloat = 80
    }
    
    enum UserAction {
        case play(_ item: MediaAttachment)
        case remove(_ item: MediaAttachment)
    }
}

#Preview {
    MediaAttachmentPreview(mediaAttachments: [], actionHandler: { action in })
}
