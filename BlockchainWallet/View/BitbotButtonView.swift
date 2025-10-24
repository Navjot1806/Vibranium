// BlockchainWallet/View/BitbotButtonView.swift

import SwiftUI
import AVKit

struct BitbotButtonView: View {
    let action: () -> Void
    
    // State for simple animation
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0

    var body: some View {
        Button(action: {
            // Add haptic feedback for a more 'impressive' feel
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                // Outer glow effect (simulated animation)
                Circle()
                    .fill(Color.pink.opacity(0.4))
                    .frame(width: 60, height: 60)
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: scale
                    )
                
                // Bot icon (Bitbot logo or symbol)
                Image(systemName: "brain.head.profile.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
                    .animation(
                        .linear(duration: 8)
                        .repeatForever(autoreverses: false),
                        value: rotation
                    )
            }
            .frame(width: 50, height: 50)
            .background(Color.pink)
            .clipShape(Circle())
            .shadow(color: .pink.opacity(0.8), radius: 10, x: 0, y: 0)
        }
        .onAppear {
            scale = 1.15
            rotation = 360.0
        }
    }
}
