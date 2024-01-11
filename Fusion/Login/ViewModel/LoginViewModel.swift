//
//  LoginViewModel.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import Foundation
import SwiftUI
import Firebase
import GoogleSignIn

class LoginViewModel: ObservableObject {
    @EnvironmentObject var coordinator: Coordinator<Router>
    @Published var profile: Profile? = nil
    @Published var email: String = "test@gmail.com"
    @Published var password: String = "qwerty"
    @Published var error: String = ""
    @Published var isLogged: Bool = false
    @Published var uid: String = ""
    @Published var message: String = ""
    @Published var isLoading: Bool = false

    func register(){
        self.isLoading = true
        Auth.auth().createUser(withEmail: email, password: password){ result, error in
            if let error = error {
                self.error = error.localizedDescription
                self.isLoading = false
            } else {
                self.message = "😎 Registration success!"
                print("😎 Registration success!")
                self.isLoading = false
            }
        }
    }
    
    func login(completion: @escaping () -> Void){
        self.isLoading = true
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if let error = error {
                self.error = error.localizedDescription
                self.isLoading = false
            } else {
                self.uid = result?.user.uid ?? ""
                print("UID: \(self.uid)")
                print("😎 Login success!")
                self.isLogged = true
                self.isLoading = false
                
                Task {
                    self.profile = try? await DataManager.shared.getProfileData()
                }
                completion()
            }
        }
    }
    
    
    func loginWithGoogle(completion: @escaping () -> Void){
        self.isLoading = true
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { [unowned self] result, error in
            if let error = error {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    self.isLoading = false
                    return
                }
                guard let uid = result?.user.uid else {
                    self.isLoading = false
                    return
                }
                self.uid = uid
                self.isLogged = true
                self.isLoading = false
                Task {
                    try? await DataManager.shared.getProfileData()
                }
                completion()
                print(self.uid)
            }
        }
    }
}

extension ObservableObject {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
