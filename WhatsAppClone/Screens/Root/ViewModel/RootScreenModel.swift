//
//  RootScreenModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 03.06.24.
//

import Foundation
import Combine

final class RootScreenModel: ObservableObject {
    @Published private(set) var authState = AuthState.pending
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = AuthManager.shared.authState.receive(on: DispatchQueue.main)
            .sink { [weak self] latestAuthState in
                self?.authState = latestAuthState
            }
        
//        AuthManager.testAccounts.forEach { email in
//            registerTestAccount(with: email)
//        }
    }
    
//    private func registerTestAccount(with email: String) {
//        Task {
//            let username = email.replacingOccurrences(of: "@test.org", with: "")
//            try? await AuthManager.shared.createAccount(for: username, with: email, and: "123456")
//        }
//    }
}
