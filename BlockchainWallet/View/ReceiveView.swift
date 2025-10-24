// ReceiveView.swift
import SwiftUI

struct ReceiveView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                Text("Your Wallet Address")
                    .font(.headline)

                Text(walletManager.walletAddress)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                // Placeholder for a QR Code
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 200))
                    .padding()

                Button(action: {
                    UIPasteboard.general.string = walletManager.walletAddress
                    print("ACTION: Address copied to clipboard")
                }) {
                    Label("Copy Address", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                Spacer()
            }
            .padding()
            .navigationTitle("Receive Crypto")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
