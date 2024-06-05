//
//  UserItem.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 03.06.24.
//

import Foundation

struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    let username: String
    let email: String
    var bio: String?
    var profileImageUrl: String? = nil
    
    var id: String {
        return uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey there! I am using WhatsUp."
    }
    
    static let placeHolder = UserItem(uid: "1234567", username: "QaUser111", email: "qa_user_111@test.org")
}

extension UserItem {
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String ?? nil
        self.profileImageUrl = dictionary[.profileImageUrl] as? String ?? nil
    }
}

extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageUrl"
}

