// BlockchainWallet/View/DuoAuthSetupView.swift

import SwiftUI

struct DuoAuthSetupView: View {
    @State private var step = 1
    @State private var isEnabled = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Two-Factor Authentication Setup")
                .font(.title2)
                .fontWeight(.bold)
            
            ProgressView(value: Double(step), total: 3)
                .padding(.horizontal)
            
            if step == 1 {
                VStack(spacing: 15) {
                    Image(systemName: "hand.raised.square.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Step 1: Install the App")
                        .font(.headline)
                    Text("Download and install the Duo Authentication mobile application on your device.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Go to App Store") {}
                        .buttonStyle(.borderedProminent)
                }
            } else if step == 2 {
                VStack(spacing: 15) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Step 2: Scan QR Code")
                        .font(.headline)
                    Text("In the Duo app, scan the unique QR code below to link your account.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    // Simulated QR Code Display
                    Text("QR-CODE-SIMULATION-KEY-XXXXX")
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            } else if step == 3 {
                VStack(spacing: 15) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Step 3: Verification")
                        .font(.headline)
                    Text("Enter the 6-digit code provided by your Duo app to confirm setup.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    TextField("6-Digit Code", text: .constant(""))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button("Enable 2FA") {
                        isEnabled = true
                        step = 4 // Move to completion
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("2FA is Enabled!")
                        .font(.headline)
                    Text("Your account is now protected with Duo Authentication.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if step < 3 {
                Button("Next Step") {
                    withAnimation {
                        step += 1
                    }
                }
                .buttonStyle(.borderedProminent)
            } else if step == 3 && isEnabled {
                 Text("Setup Complete")
            }

        }
        .padding()
        .navigationTitle("2FA Setup")
        .navigationBarTitleDisplayMode(.inline)
    }
}
