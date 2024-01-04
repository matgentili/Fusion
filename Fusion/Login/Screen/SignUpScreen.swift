//
//  SignUpScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 29/12/23.
//

import SwiftUI
import SirioKitIOS
import Firebase

struct SignUpScreen : View {
    @EnvironmentObject var coordinator: Coordinator<Router>
    
    @State var psw1: String = ""
    @State var psw2: String = ""

    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .angleLeft, action: {
            coordinator.pop()
        })
    }
    
    var body: some View {
        AppNavigationView {
            VStack(spacing: 12) {
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .padding(.top, -20)
                    .padding(.bottom, 50)
                
                HStack {
                    SirioText(text: "Create your Account", typography: .label_md_700)
                    Spacer()
                }
                
                SirioTextField(placeholder: "Email",
                               text: $coordinator.loginEnv.email,
                               icon: nil,
                               helperText: nil)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
                
                SirioTextField(placeholder: "Password",
                               text: $psw1,
                               icon: nil,
                               helperText: nil,
                               isSecureText: .constant(true))
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                
                
                SirioTextField(placeholder: "Confirm Password",
                               text: $psw2,
                               icon: nil,
                               helperText: nil,
                               isSecureText: .constant(true))
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                
                //Spacer()
                
                ButtonTextOnly(style: .primary, size: .large, text: "Sign up", isFullSize: true ,action: {
                    if psw1 == psw2 {
                        coordinator.loginEnv.password = psw1
                        coordinator.loginEnv.register()
                    } else {
                        coordinator.loginEnv.error = Localizable.anErrorHasOccurred
                    }
                    
                })
                .padding(.vertical)
                
                HStack {
                    Spacer()
                    
                    SirioText(text: "Or sign up with", typography: .label_md_600)
                    
                    Spacer()
                }
                .padding(.vertical)
                
                HStack(spacing: 16) {
                    Button(action: {
                        coordinator.loginEnv.loginWithGoogle(completion: {
                            coordinator.show(.main)
                        })
                    }, label: {
                        Image("google")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    })
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)

                    Button(action: {
                        coordinator.loginEnv.error = Localizable.anErrorHasOccurred
                    }, label: {
                        Image("fb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    })
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)

                    Button(action: {
                        coordinator.loginEnv.error = Localizable.anErrorHasOccurred
                    }, label: {
                        Image("apple")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    })
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                }
                .padding(.vertical)
                
                Spacer()
                
            }.padding()
                .setAppNavigationBarItems(leftItem: leftItem, rightItems: nil)
        }
        .progressBarView(isPresented: $coordinator.loginEnv.isLoading)
        .dialog(isPresented: .constant(!coordinator.loginEnv.error.isEmpty), type: .alert, title: "Warning", subtitle: coordinator.loginEnv.error, onTapCloseAction: {
            self.coordinator.loginEnv.error = ""
        })
        
        .dialog(isPresented: .constant(!coordinator.loginEnv.message.isEmpty), type: .default, title: "Info", subtitle: coordinator.loginEnv.message, onTapCloseAction: {
            self.coordinator.loginEnv.message = ""
            self.coordinator.pop()
        })
    }
}

#Preview {
    SignUpScreen()
}
