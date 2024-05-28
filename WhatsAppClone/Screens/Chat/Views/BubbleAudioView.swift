//
//  BubbleAudioView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 28.05.24.
//

import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem
    
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    
    var body: some View {
        VStack(alignment: item.horizontalAlignment, spacing: 4) {
            HStack {
                playButton()
                Slider(value: $sliderValue, in: sliderRange)
                    .tint(.gray)
                
                Text("04:00")
                    .foregroundStyle(.gray)
                
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(item.backgroundColor)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .applyTail(item.direction)
            
            timeStampTextView()
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .received ? 5 : 100)
        .padding(.trailing, item.direction == .received ? 100 : 5)
    }
    
    private func playButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "play.fill")
                .padding(10)
                .background(item.direction == .received ? .green : .white)
                .clipShape(.circle)
                .foregroundStyle(item.direction == .sent ? .black : .white)
        }
    }
    
    private func timeStampTextView() -> some View {
        HStack {
            Text("3:05 PM")
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
        BubbleAudioView(item: MessageItem.stubMessages[3])
        BubbleAudioView(item: MessageItem.stubMessages[2])
           
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.4))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
   
   
}
