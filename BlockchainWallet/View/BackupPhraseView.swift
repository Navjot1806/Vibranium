// BlockchainWallet/View/BackupPhraseView.swift

import SwiftUI

struct BackupPhraseView: View {
    // In a real app, this would be securely retrieved and displayed.
    private let backupPhrase = "jungle abuse whisper snake swift empty tenant obtain shy motor cause lounge"

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Security Warning")
                .font(.title2)
                .fontWeight(.bold)

            Text("Never share your backup phrase with anyone. Store it in a secure, offline location.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(backupPhrase)
                .font(.system(.title3, design: .monospaced))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                UIPasteboard.general.string = backupPhrase
            }) {
                Label("Copy Phrase", systemImage: "doc.on.doc")
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Backup Phrase")
        .navigationBarTitleDisplayMode(.inline)
    }
}
