// BlockchainWallet/View/SignupView.swift

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    private let validation = Validation()

    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)

            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                // FIX: Attempt to suppress system autofill hints by specifying a non-credential text content type.
                .textContentType(.newPassword)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                // FIX: Attempt to suppress system autofill hints.
                .textContentType(.newPassword)

            Button(action: {
                if !validation.isValidEmail(email) {
                    alertTitle = "Signup Failed"
                    alertMessage = "Please enter a valid email."
                    showingAlert = true
                    return
                }
                if !validation.isValidPassword(password) {
                    alertTitle = "Signup Failed"
                    alertMessage = "Password must be at least 8 characters long, with one uppercase letter, one number, and one special character."
                    showingAlert = true
                    return
                }
                if password != confirmPassword {
                    alertTitle = "Signup Failed"
                    alertMessage = "Passwords do not match."
                    showingAlert = true
                    return
                }
                
                let newUser = User(email: email, password: password)
                if authManager.signUp(user: newUser) {
                    // MODIFICATION: Show success alert and prepare to go back to login
                    alertTitle = "Success"
                    alertMessage = "Your account has been created. Please log in."
                    showingAlert = true
                } else {
                    alertTitle = "Signup Failed"
                    alertMessage = "An account with this email already exists."
                    showingAlert = true
                }
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // If signup was successful, dismiss the view to go back to Login
                        if alertTitle == "Success" {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("", displayMode: .inline)
    }
}

