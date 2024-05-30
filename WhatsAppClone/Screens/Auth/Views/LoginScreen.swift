//
//  LoginScreen.swift
//  WhatsAppClone
//
//  Created by Jan Alexander Neumann on 28.05.24.
//

import SwiftUI

struct LoginScreen: View {
    
    @StateObject private var authScreenModel = AuthScreenModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                AuthHeaderView()
                AuthTextField(type: .email, text: $authScreenModel.email)
                AuthTextField(type: .password, text: $authScreenModel.password)
                forgotPasswordButton()
                
                AuthButton(title: "Log in now") {
                    
                }
                .disabled(authScreenModel.disableLoginButton)
                
                Spacer()
                
                signUpButton()
                    .padding(.bottom, 32)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.teal.gradient)
            .ignoresSafeArea()
        }
    }
    
    private func forgotPasswordButton() -> some View {
        Button {
            
        } label: {
            Text("Forgot Password ?")
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 32)
                .bold()
                .padding(.vertical)
        }
    }
    
    private func signUpButton() -> some View {
        NavigationLink {
            SignUpScreen(authScreenModel: authScreenModel)
        } label: {
            HStack {
                Image(systemName: "sparkles")
                
                (
                    Text("Don't have an account ? ")
                    +
                    Text("Create one")
                        .bold()
                )
                
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    LoginScreen()
}
