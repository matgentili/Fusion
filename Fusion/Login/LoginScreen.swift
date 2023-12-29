//
//  LoginScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS
import Firebase

struct LoginScreen: View {
    
    //@StateObject var vm = LoginViewModel()
    @EnvironmentObject var coordinator: Coordinator<Router>
    
    var body: some View {
        VStack {
            SirioIcon(data: .init(icon: .facebook))
                .frame(width: 120, height: 120)
            
            SirioTextField(placeholder: "Email",
                           text: $coordinator.loginEnv.email,
                           icon: nil,
                           helperText: nil)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.next)

            SirioTextField(placeholder: "Password",
                           text: $coordinator.loginEnv.password,
                           icon: nil,
                           helperText: nil,
                           isSecureText: .constant(true))
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
            
            Spacer()
            
            
            ButtonTextOnly(style: .primary, size: .large, text: "Login", action: {
                coordinator.loginEnv.login(completion: {
                    coordinator.show(.main)
                })
            })
            
            ButtonTextOnly(style: .primary, size: .large, text: "Sign up", action: {
                coordinator.loginEnv.register()
            })
            
            ButtonTextOnly(style: .primary, size: .large, text: "Google", action: {
                coordinator.loginEnv.loginWithGoogle()
            })
        }
        .dialog(isPresented: .constant(!coordinator.loginEnv.error.isEmpty), type: .alert, title: "Warning", subtitle: coordinator.loginEnv.error, onTapCloseAction: {
            self.coordinator.loginEnv.error = ""
        })
        .padding()
    }
}

#Preview {
    LoginScreen()
}
