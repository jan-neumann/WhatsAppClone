//
//  CommunityTabScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 20.05.24.
//

import SwiftUI

struct CommunityTabScreen: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Image(.communities)
                    
                    Group {
                        Text("Stay connected with a community")
                            .font(.title2)
                        Text("Communities bring members together in topic-based groups. Any community you're added to will appear here.")
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 5)
                    
                    Button("See example communities >") { }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                    
                    createNewCommunityButton()
                }
                .padding()
                .navigationTitle("Communities")
            }
        }
    }
    
    private func createNewCommunityButton() -> some View {
        Button {
            
        } label: {
            Label("New Community", systemImage: "plus")
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .padding(10)
                .background(.blue)
                .clipShape(.rect(cornerRadius: 10, style: .continuous))
                .padding()
        }
       
    }
}

#Preview {
    CommunityTabScreen()
}
