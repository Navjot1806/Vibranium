////
////  QuickActionButton.swift
////  BlockchainWallet
////
////  Created by csuftitan on 9/9/25.
////
//import SwiftUI
//import Charts
//import CryptoKit
//import Network
//
//struct QuickActionButton: View {
//    let icon: String
//    let title: String
//    let color: Color
//    // ✅ ADDED ACTION CLOSURE
//    let action: () -> Void
//    
//    var body: some View {
//        // ✅ WRAPPED IN A BUTTON
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Image(systemName: icon)
//                    .font(.title2)
//                    .foregroundColor(color)
//                Text(title)
//                    .font(.caption)
//                    .foregroundColor(.primary)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 15)
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//        }
//    }
//}


// BlockchainWallet/QuickActionButton.swift

import SwiftUI
import Charts
import CryptoKit
import Network

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    // ✅ ADDED ACTION CLOSURE
    let action: () -> Void
    
    var body: some View {
        // ✅ WRAPPED IN A BUTTON
        Button(action: action) {
            VStack(spacing: 8) {
                // MODIFIED: Circular Icon Container matching screenshot style
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color.black) // Icon is black inside the circular white button
                    .frame(width: 45, height: 45)
                    .background(Color.white.opacity(0.8)) // White circular background
                    .clipShape(Circle())
                
                // Text Title remains at the bottom
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            // Removed the fixed large background block
            .frame(maxWidth: .infinity)
        }
    }
}
