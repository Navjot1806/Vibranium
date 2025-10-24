// BlockchainWallet/View/ChangePasswordView.swift

import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var isPasswordValid: Bool {
        // Simple check for demo purposes
        !newPassword.isEmpty && newPassword == confirmNewPassword
    }

    var body: some View {
        Form {
            Section(header: Text("Current Password")) {
                SecureField("Current Password", text: $currentPassword)
            }
            
            Section(header: Text("New Password")) {
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmNewPassword)
            }
            
            Button("Update Password") {
                if newPassword != confirmNewPassword {
                    alertMessage = "New passwords do not match."
                    showingAlert = true
                } else if newPassword.count < 8 {
                    alertMessage = "Password must be at least 8 characters."
                    showingAlert = true
                } else {
                    // Simulate a successful password change
                    alertMessage = "Your password has been successfully updated."
                    currentPassword = ""
                    newPassword = ""
                    confirmNewPassword = ""
                    showingAlert = true
                }
            }
            .disabled(!isPasswordValid || currentPassword.isEmpty)
            .alert("Password Change", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
