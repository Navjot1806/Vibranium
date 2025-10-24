//
//  ImportWalletView.swift
//  BlockchainWallet
//
//  Created by csuftitan on 9/9/25.
//
import SwiftUI
import Charts
import CryptoKit
import Network

struct ImportWalletView: View {
    @Binding var privateKeyInput: String
    let onImport: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Import your private key or seed phrase")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextEditor(text: $privateKeyInput)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                Button(action: onImport) {
                    Text("Import Wallet")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(privateKeyInput.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(privateKeyInput.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Wallet")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
