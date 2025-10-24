// BlockchainWallet/View/SecuritySettingsView.swift

import SwiftUI
import LocalAuthentication // Import LocalAuthentication

struct SecuritySettingsView: View {
    @State private var isFaceIdEnabled = true
    @State private var showingBiometricAlert = false // New state for biometric permission

    // --- NEW: Function to request biometric permission (simulated) ---
    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        // Check if the device can use biometrics (Face ID or Touch ID)
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enable biometric access to your wallet.") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isFaceIdEnabled = true
                    } else {
                        // User canceled or failed to authenticate
                        isFaceIdEnabled = false
                    }
                }
            }
        } else {
            // Biometrics not available or permissions denied
            showingBiometricAlert = true
            isFaceIdEnabled = false
        }
    }

    var body: some View {
        Form {
            // --- Biometrics Section ---
            Section(header: Text("Biometrics")) {
                Toggle(isOn: $isFaceIdEnabled.onChange(authenticate)) {
                    Text("Enable Biometric Unlock")
                }
            }
            // Alert user if biometrics are unavailable
            .alert("Biometric Unavailable", isPresented: $showingBiometricAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your device does not support Face ID/Touch ID, or permission was denied. Please use your password.")
            }


            // --- Authentication Management Section ---
            Section(header: Text("Authentication")) {
                // Navigates to the new view
                NavigationLink(destination: ChangePasswordView()) {
                    Text("Change Password")
                }
                
                // Navigates to the new view
                NavigationLink(destination: DuoAuthSetupView()) {
                    Text("Setup Duo Authentication (2FA)")
                }
            }
            
            // --- Regulatory and Information Links ---
            Section(header: Text("Policies & Help")) {
                Link("Security Policy", destination: URL(string: "https://www.example.com/security-policy")!)
                    .foregroundColor(.blue)
                
                Link("Terms of Service", destination: URL(string: "https://www.example.com/terms-of-service")!)
                    .foregroundColor(.blue)
            }
        }
        .navigationTitle("Security Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Simple extension to add an action to a binding's onChange
extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> where Value == Bool {
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
