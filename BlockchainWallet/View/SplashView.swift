//
//  SplashView.swift
//  Vibranium
//
//  Created by AI on 2025/09/29.
//
import SwiftUI
import AVKit

struct SplashView: View {
    // State to track video completion (only used to initialize the video player)
    @State private var videoAnimationFinished: Bool = false
    @State private var elementsVisible: Double = 0.0 // Controls visibility of logo text/progress
    
    // State to trigger the overall screen dismissal in ContentView
    @Binding var isSplashReadyToDismiss: Bool
    
    // Define theme colors
    private let primaryBlack = Color(red: 0.0, green: 0.0, blue: 0.0)
    private let primaryPink = Color(red: 239.0/255.0, green: 87.0/255.0, blue: 101.0/255.0)
    private let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05)
    
    var body: some View {
        ZStack {
            darkBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 50) {
                
                // 1. Video Player
                VideoSplashView(isFinished: $videoAnimationFinished)
                    .frame(width: 300, height: 300)
                    .cornerRadius(20)
                    .shadow(color: primaryBlack.opacity(0.5), radius: 10)
                    
                // 2. Main Logo (App Name & Text)
                VStack(spacing: 10) {
                    Text("VIBRANIUM")
                        .font(.custom("HelveticaNeue-CondensedBlack", size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(primaryPink)
                        .opacity(elementsVisible)
                    
                    // 3. Necessary Text
                    Text("SECURE. DECENTRALIZED. INSTANT.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .opacity(elementsVisible)
                }

                // 4. Loading Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryPink))
                    .scaleEffect(1.5)
                    .padding(.top, 40)
                    .opacity(elementsVisible)
            }
            .onAppear {
                // Initial fade in for the static elements
                withAnimation(.easeIn(duration: 0.5)) {
                    elementsVisible = 1.0
                }
                
                // --- FIX: Timer to trigger dismissal after fixed duration ---
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    // Trigger haptics and dismissal
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    
                    self.isSplashReadyToDismiss = true
                }
            }
        }
    }
}
