//
//  AuthScreenModel.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 30.05.24.
//

import Foundation

final class AuthScreenModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    // MARK: - Computed Properties
    
    var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    var disableSignupButton: Bool {
        email.isEmpty || password.isEmpty || username.isEmpty || isLoading
    }
}
