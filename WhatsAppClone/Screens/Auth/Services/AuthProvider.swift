//
//  AuthProvider.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 30.05.24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

enum AuthState {
    case pending
    case loggedIn(UserItem)
    case loggedOut
}

protocol AuthProvider {
    static var shared: AuthProvider { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    func autoLogin() async
    func login(with email: String, and password: String) async throws
    func createAccount(for username: String, with email: String, and password: String) async throws
    func logOut() async throws
}

enum AuthError: Error {
    case accountCreationFailed(_ description: String)
    case failedToSaveUserInfo(_ description: String)
    case emailLoginFailed(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return description
        case .failedToSaveUserInfo(let description):
            return description
        case .emailLoginFailed(let description):
            return description
        }
    }
}

final class AuthManager: AuthProvider {
    
    private init() {
        Task { await autoLogin() }
    }
    
    static let shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
            fetchCurrentUserInfo()
        }
    }
    
    func login(with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo()
            print("🔐 Successfully signed in \(authResult.user.email ?? "")")
        } catch {
            print("🔐 Failed to log in \(email)")
            throw AuthError.emailLoginFailed(error.localizedDescription)
        }
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            try await saveUserInfoDatabase(user: newUser)
            self.authState.send(.loggedIn(newUser))
        } catch {
            print("🔐 Failed to Create an Account: \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(error.localizedDescription)
        }
    }
    
    func logOut() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("🔐 Successfully logged out!")
        } catch {
            print("🔐 Failed to log out current user: \(error.localizedDescription)")
        }
    }
}

extension AuthManager {
    private func saveUserInfoDatabase(user: UserItem) async throws {
        do {
            let userDictionary: [String: Any] = [.uid: user.uid, .username: user.username, .email: user.email]
            try await FirebaseConstants.UserRef.child(user.uid).setValue(userDictionary)
        } catch {
            print("🔐 Failed to Save Created User Info to Database: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(error.localizedDescription)
        }
    }
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).observe(.value) { [weak self] snapshot in
            
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let loggedInUser = UserItem(dictionary: userDict)
            self?.authState.send(.loggedIn(loggedInUser))
            print("🔐 \(loggedInUser.username) is logged in")
        } withCancel: { error in
            print("Failed to get current user info")
        }
    }
}

extension AuthManager {
    
    static let testAccounts: [String] = [
        "QaUser1@test.org",
        "QaUser2@test.org",
        "QaUser3@test.org",
        "QaUser4@test.org",
        "QaUser5@test.org",
        "QaUser6@test.org",
        "QaUser7@test.org",
        "QaUser8@test.org",
        "QaUser9@test.org",
        "QaUser10@test.org",
        "QaUser11@test.org",
        "QaUser12@test.org",
        "QaUser13@test.org",
        "QaUser14@test.org",
        "QaUser15@test.org",
        "QaUser16@test.org",
        "QaUser17@test.org",
        "QaUser18@test.org",
        "QaUser19@test.org",
        "QaUser20@test.org",
        "QaUser21@test.org",
        "QaUser22@test.org",
        "QaUser23@test.org",
        "QaUser24@test.org",
        "QaUser25@test.org",
        "QaUser26@test.org",
        "QaUser27@test.org",
        "QaUser28@test.org",
        "QaUser29@test.org",
        "QaUser30@test.org",
        "QaUser31@test.org",
        "QaUser32@test.org",
        "QaUser33@test.org",
        "QaUser34@test.org",
        "QaUser35@test.org",
        "QaUser36@test.org",
        "QaUser37@test.org",
        "QaUser38@test.org",
        "QaUser39@test.org",
        "QaUser40@test.org",
        "QaUser41@test.org",
        "QaUser42@test.org",
        "QaUser43@test.org",
        "QaUser44@test.org",
        "QaUser45@test.org",
        "QaUser46@test.org",
        "QaUser47@test.org",
        "QaUser48@test.org",
        "QaUser49@test.org",
        "QaUser50@test.org",
    ]
}
