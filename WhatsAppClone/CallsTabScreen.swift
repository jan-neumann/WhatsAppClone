//
//  CallsTabScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 17.05.24.
//

import SwiftUI

struct CallsTabScreen: View {
    
    @State private var searchText = ""
    @State private var callHistory: CallHistory = CallHistory.all
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CreateCallLinkSection()
                }
                
            }
            .navigationTitle("Calls")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                principalNavItem()
                trailingNavItem()
            }
        }
    }
}

extension CallsTabScreen {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Edit") {
                
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "phone.arrow.up.right")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func principalNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $callHistory) {
                ForEach(CallHistory.allCases) { item in
                    Text(item.rawValue.capitalized)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
            
        }
       
    }
    
    private enum CallHistory: String, CaseIterable, Identifiable {
        var id: String {
            return rawValue
        }
        
        case all, missed
    }
}

private struct CreateCallLinkSection: View {
    var body: some View {
        HStack {
            Image(systemName: "link")
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(.circle)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading) {
                Text("Create Call Link")
                    .foregroundStyle(.blue)
                Text("Share a link for your WhatsApp call")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
    }
}
#Preview {
    CallsTabScreen()
}
