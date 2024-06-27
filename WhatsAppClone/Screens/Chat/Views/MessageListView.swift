//
//  MessageListView.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 23.05.24.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {

    typealias UIViewControllerType = MessageListController
    private var viewModel: ChatRoomViewModel
    
    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController(viewModel)
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) { }
    
  
}

#Preview {
    MessageListView(viewModel: ChatRoomViewModel(channel: .placeholder))
}
