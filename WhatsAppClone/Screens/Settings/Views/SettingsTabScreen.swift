//
//  SettingsTabScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 21.05.24.
//

import SwiftUI

struct SettingsTabScreen: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
//                SettingsItemView()
//                SettingsItemView()
//                SettingsItemView()
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
        }
        
    }
}

#Preview {
    SettingsTabScreen()
}
