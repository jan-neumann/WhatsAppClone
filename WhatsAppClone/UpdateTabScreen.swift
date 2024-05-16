//
//  UpdateTabScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 16.05.24.
//

import SwiftUI

struct UpdateTabScreen: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                StatusSectionHeader()
                    .listRowBackground(Color.clear)
                StatusSection()
       
            }
            .listStyle(.grouped)
            .navigationTitle("Updates")
            .searchable(text: $searchText)
        }
    }
}

private struct StatusSectionHeader: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.dashed")
                .foregroundStyle(.blue)
                .imageScale(.large)
            (
                Text("Use Status to share photos, text and videos that disappear in 24 hours.")
                +
                Text(" ")
                +
                Text("Status Privacy")
                    .foregroundStyle(.blue).bold()
            )
            
            Image(systemName: "xmark")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(.whatsAppWhite)
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        
    }
}

private struct StatusSection: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 55, height: 55)
            
            VStack(alignment: .leading) {
                Text("My Status")
                    .font(.callout)
                    .bold()
                
                Text("Add to my status")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            cameraButton()
            
            pencilButton()
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(.circle)
                .bold()
        }
    }
    
    private func pencilButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "pencil")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(.circle)
                .bold()
        }
    }
}

private struct RecentUpdatesItemView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 55, height: 55)
        }
    }
}

#Preview {
    UpdateTabScreen()
}
