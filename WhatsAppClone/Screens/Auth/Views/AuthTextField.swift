//
//  AuthTextField.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 29.05.24.
//

import SwiftUI

struct AuthTextField: View {
    
    let type: InputType
    
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: type.imageName)
                .fontWeight(.semibold)
                .frame(width: 30)
            
            switch type {
    
            case .password:
                SecureField(type.placeholder, text: $text)
            default:
                TextField(type.placeholder, text: $text)
                    .keyboardType(type.keyboardType)
            }

        }
        .foregroundStyle(.white)
        .padding()
        .background(.white.opacity(0.3))
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 32)
    }
}

extension AuthTextField {
    
    enum InputType {
        case email
        case password
        case custom(_ placeholder: String, _ iconName: String)
        
        var placeholder: String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .custom(let placeholder, _):
                return placeholder
            }
        }
        
        var imageName: String {
            switch self {
            case .email:
                return "envelope"
            case .password:
                return "lock"
            case .custom(_, let iconname):
                return iconname
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
        
    }
}


#Preview {
    ZStack {
        Color.teal
        VStack {
            AuthTextField(type: .email, text: .constant(""))
            AuthTextField(type: .password, text: .constant(""))
            AuthTextField(type: .custom("Birthday", "birthday.cake"), text: .constant(""))
        }
    }
    .ignoresSafeArea()
      
}
