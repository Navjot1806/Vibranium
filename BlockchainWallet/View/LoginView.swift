// BlockchainWallet/View/LoginView.swift

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSignup = false

    private let validation = Validation()

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome Back")
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

                Button(action: {
                    if !validation.isValidEmail(email) {
                        alertMessage = "Please enter a valid email."
                        showingAlert = true
                        return
                    }

                    let credentials = Credentials(email: email, password: password)
                    if !authManager.login(credentials: credentials) {
                        alertMessage = "Invalid credentials. Please try again or sign up."
                        showingAlert = true
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                Spacer()
                
                NavigationLink(destination: SignupView().environmentObject(authManager), isActive: $showingSignup) {
                    Button("Don't have an account? Sign Up") {
                        showingSignup = true
                    }
                }
            }
            .padding()
        }
    }
}


