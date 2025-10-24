// BlockchainWallet/View/NetworkSettingsView.swift

import SwiftUI

struct NetworkSettingsView: View {
    @State private var selectedNetwork = "Mainnet"
    let networks = ["Mainnet", "Sepolia Testnet", "Goerli Testnet"]

    var body: some View {
        Form {
            Section(header: Text("Ethereum Network")) {
                Picker("Select Network", selection: $selectedNetwork) {
                    ForEach(networks, id: \.self) { network in
                        Text(network)
                    }
                }
            }
            
            Section(header: Text("Network Details")) {
                HStack {
                    Text("Status")
                    Spacer()
                    Text("Connected")
                        .foregroundColor(.green)
                }
                HStack {
                    Text("Chain ID")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Network Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
