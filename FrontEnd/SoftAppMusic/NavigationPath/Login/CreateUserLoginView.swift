//
//  CreateUserLoginView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/9/24.
//

import Foundation
import SwiftData
import SwiftUI

struct PasswordRequirements: View {
    var requirement: String
    @Binding var requirementSatisfied: Bool
    @Binding var submissionAttempt: Bool
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
    
    var body: some View {
        HStack {
            Image(systemName: requirementSatisfied ? "checkmark.square" : "square")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(requirementSatisfied ? .primary : Color.red)
            Text(requirement)
                .foregroundStyle(submissionAttempt && !requirementSatisfied ? .red : Color.primary)
        }
    }
}


struct CreateUserLoginView: View {
    @ObservedObject var userLogin = FetchUserLogin()
    
    /// User Application Seettings
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) private var dbContext
    @Query private var masterSettingsModel: [MasterSettingsModel]
    @State var errorDuringLoginAttempt: Bool = false
    private var settings: MasterSettingsModel { masterSettingsModel.first! }
    private var userProfileCreated: Binding<Bool> {
        Binding { settings.userProfileCreated }
        set: { settings.userProfileCreated = $0 }
    }
    
    
    /// username and password status
    private var usernameErrorStatus: Binding<String> {
        Binding {
            switch userLogin.usernameStatus {
            case .empty:
                return userLogin.enteredUserName.isEmpty ? "Please enter a username" : ""
            case .valid:
                return ""
            default:
                return "Username already in use"
            }
        }
        set: { _ in return}
    }
    @State private var eightCharacters = false
    @State private var specialCharacter = false
    @State private var number = false
    @State private var passwordsMatch = false
    
    private var password1: Binding<String> {
        Binding { userLogin.enteredPassword }
        set: {
            passwordsMatch = enteredPassword2 == $0 && !enteredPassword2.isEmpty
            eightCharacters = $0.count >= 8
            specialCharacter = $0.contains(/[!@#\$%\^&\*\(\),\.'"]/)
            number = $0.contains(/\d/)
            userLogin.enteredPassword = $0
        }
    }
    @State private var enteredPassword2: String = ""
    private var password2: Binding<String> {
        Binding { enteredPassword2 }
        set: {
            passwordsMatch = userLogin.enteredPassword == $0 && !enteredPassword2.isEmpty
            enteredPassword2 = $0
        }
    }
    
    @State private var submissionAttempt = false
    @State private var displayTermsOfService = false
    
    private var passwordErrorStatus: Binding<String> {
        Binding {
            switch userLogin.passwordStatus {
            case .empty:
                return userLogin.enteredPassword.isEmpty ? "Please enter a password" : ""
            case .valid:
                return ""
            case .invalid:
                return "Password does not match username"
            case .tooManyAttempts:
                return "Too many attempts.  Account has been locked."
            default:
                return ""
            }
        }
        set: { _ in return}
    }
    
    var body: some View {
        Group {
            if displayTermsOfService {
                TermsOfServiceView {
                    acceptTos()
                }
            } else {
                VStack {
                    Spacer()
                    Spacer()
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                    Spacer()
                    
                    if errorDuringLoginAttempt {
                        Text("Error during login. Please try again")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    
                    LoginTextFields("Username",
                                    content: $userLogin.enteredUserName,
                                    errorStatus: usernameErrorStatus.wrappedValue)
                    .padding()
                    
                    LoginTextFields("Password",
                                    content: password1,
                                    errorStatus: "",
                                    isPassword: true)
                    .padding()
                    
                    VStack(alignment: .leading){
                        PasswordRequirements(requirement: "8 characters", requirementSatisfied: $eightCharacters, submissionAttempt: $submissionAttempt)
                        PasswordRequirements(requirement: "One Number", requirementSatisfied: $number, submissionAttempt: $submissionAttempt)
                        PasswordRequirements(requirement: "One Special Character", requirementSatisfied: $specialCharacter, submissionAttempt: $submissionAttempt)
                        PasswordRequirements(requirement: "Passwords Match", requirementSatisfied: $passwordsMatch, submissionAttempt: $submissionAttempt)
                    }
                    
                    LoginTextFields("Password",
                                    content: password2,
                                    errorStatus: "",
                                    isPassword: true)
                    .padding()
                    
                    Button(action: {
                        Task {
                            guard await validateUserCreationAndLogin() else {
                                return
                            }
                            displayTermsOfService = true
                        }
                    }, label: {
                        if case .inprogress = userLogin.status {
                            ProgressView()
                        } else {
                            Text("Let's Move")
                        }
                    })
                    .disabled( {
                        if case .inprogress = userLogin.status {
                            return true
                        } else {
                            return false
                        }
                    }())
                    .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue, borderColor: StyleConstants.DarkBlue, textColor: Color.white))
                    
                    Spacer()

                    Text("Already a user? Click here to log in.")
                    NavigationLink("Log in", value: NavigationViews.loginView)
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func validateUserCreationAndLogin() async -> Bool {
        submissionAttempt = true
        
        // validate password requirements satisfied
        guard eightCharacters && number && specialCharacter && passwordsMatch else {
            return false
        }

        // validate username not in use and create user
        let createRequestStatus = await userLogin.createUser()
        guard createRequestStatus else {
            NSLog("Invalid create request")
            return false
        }
        
        // generate token and login
        let token = await userLogin.attemptLogin(token: nil)
        guard let token else {
            errorDuringLoginAttempt = true
            return false
        }
        
        // update app data with token and email
        appData.currentToken = token
        appData.currentUserEmail = userLogin.enteredUserName
        
        
        return true
//        // update master settings model with initial login
//        masterSettingsModel.first!.userProfileCreated = true
//        appData.viewPath.append(NavigationViews.userProfileView(createUserProfile: true))
    }
    
    private func acceptTos() {
        displayTermsOfService = false
        
        // update master settings model with initial login
        masterSettingsModel.first!.userProfileCreated = true
        appData.viewPath.append(NavigationViews.userProfileView(createUserProfile: true))
    }
}
