//
//  AddGroupChatPartnersScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 05.06.24.
//

import SwiftUI

struct AddGroupChatPartnersScreen: View {
    @State private var searchText = ""
    var body: some View {
        List {
            Text("PLACEHOLDER")
        }
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search name or number"
        )
    }
}

#Preview {
    NavigationStack {
        AddGroupChatPartnersScreen()
    }
}
