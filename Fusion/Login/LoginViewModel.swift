//
//  LoginViewModel.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import Foundation
import SwiftUI
import Firebase

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: String = ""
    
    func register(){
        Auth.auth().createUser(withEmail: email, password: password){ result, error in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                print("😎 Registration success!")
            }
        }
    }
    
    func login(){
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                print("😎 Login success!")
            }
        }
    }
}
