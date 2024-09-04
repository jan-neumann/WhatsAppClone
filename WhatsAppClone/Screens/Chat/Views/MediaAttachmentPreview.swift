//
//  MediaAttachmentPreview.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 03.09.24.
//

import SwiftUI

struct MediaAttachmentPreview: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                audioAttachmentPreview()
                ForEach(0..<12) { _ in
                    thumbnailImageView()
                }
            }
        }
        .frame(height: Constants.listHeight)
        .frame(maxWidth: .infinity)
        .background(.whatsAppWhite)
        
    }
    
    private func thumbnailImageView() -> some View {
        Button {
            
        } label: {
            Image(.stubImage0)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.imageDim, height: Constants.imageDim)
                .clipShape(.rect(cornerRadius: 5))
                .overlay(alignment: .topTrailing) {
                    cancelButton()
                }
                .overlay {
                    playButton("play.fill")
                }
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            
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
    
    private func playButton(_ systemName: String) -> some View {
        Button {
            
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
    
    private func audioAttachmentPreview() -> some View {
        ZStack {
            LinearGradient(colors: [.green, .green.opacity(0.8), .teal],
                           startPoint: .topLeading,
                           endPoint: .bottom
            )
            playButton("mic.fill")
                .padding(.bottom, 15)
        }
        .frame(width: Constants.imageDim * 2, height: Constants.imageDim)
        .clipShape(.rect(cornerRadius: 5))
        .overlay(alignment: .topTrailing) {
            cancelButton()
        }
        .overlay(alignment: .bottomLeading) {
            Text("Test mp3 file name here")
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
}

#Preview {
    MediaAttachmentPreview()
}
