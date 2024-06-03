//
//  FirebaseConstants.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 03.06.24.
//

import Foundation
import Firebase
import FirebaseStorage

enum FirebaseConstants {
    private static let DatabaseRef = Database.database().reference()
    static let UserRef = DatabaseRef.child("users")
}
