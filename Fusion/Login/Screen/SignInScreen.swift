//
//  LoginScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS
import Firebase

struct SignInScreen: View {
    
    @EnvironmentObject var coordinator: Coordinator<Router>
    
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .bars, action: {
            
        })
    }
    
    var body: some View {
        AppNavigationView {
            VStack(spacing: 12) {
                SirioIcon(data: .init(icon: .facebook))
                    .frame(width: 120, height: 120)
                
                
                HStack {
                    SirioText(text: "Login to your Account", typography: .label_md_700)
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
                               text: $coordinator.loginEnv.password,
                               icon: nil,
                               helperText: nil,
                               isSecureText: .constant(true))
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                
                //Spacer()
                
                
                ButtonTextOnly(style: .primary, size: .large, text: "Sign in", isFullSize: true ,action: {
                    coordinator.loginEnv.login(completion: {
                        coordinator.show(.main)
                    })
                })
                .padding(.vertical)
                
                HStack {
                    Spacer()
                    
                    SirioText(text: "Or sign in with", typography: .label_md_600)
                    
                    Spacer()
                }
                .padding(.top)
                
                HStack(spacing: 16) {
                    Button(action: {
                        coordinator.loginEnv.loginWithGoogle(completion: {
                            coordinator.show(.main)
                        })
                    }, label: {
                        Image("google")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    })

                    Button(action: {
                        coordinator.loginEnv.error = Localizable.anErrorHasOccurred
                    }, label: {
                        Image("fb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    })
                }
                .padding(.vertical)
                
                Spacer()
                
                Button(action: {
                    coordinator.show(.signUp)
                }, label: {
                    HStack {
                        SirioText(text: "Don't have an account?", typography: .label_md_600)
                            .foregroundStyle(Color.black)

                        SirioText(text: "Sign up", typography: .label_md_600)
                            .foregroundStyle(Color.blue)
                    }
                })
                
            }.padding()
        }
        .dialog(isPresented: .constant(!coordinator.loginEnv.error.isEmpty), type: .alert, title: "Warning", subtitle: coordinator.loginEnv.error, onTapCloseAction: {
            self.coordinator.loginEnv.error = ""
        })
    }
}

#Preview {
    SignInScreen()
}






//
//
//    ButtonTextOnly(style: .primary, size: .large, text: "Sign up", action: {
//        coordinator.loginEnv.register()
//    })
//
//    ButtonTextOnly(style: .primary, size: .large, text: "Google", action: {
//        coordinator.loginEnv.loginWithGoogle(completion: {
//            coordinator.show(.main)
//        })
//    })
//}
//.dialog(isPresented: .constant(!coordinator.loginEnv.error.isEmpty), type: .alert, title: "Warning", subtitle: coordinator.loginEnv.error, onTapCloseAction: {
//    self.coordinator.loginEnv.error = ""
//})
//.padding()
