// BlockchainWallet/View/VideoSplashView.swift

import SwiftUI
import AVKit
import AVFoundation

// IMPORTANT: This view expects a video file named "BlackPantherRun.mp4" in the app bundle.

struct VideoSplashView: UIViewControllerRepresentable {
    @Binding var isFinished: Bool // State to signal when the screen can transition

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        // --- FIX ATTEMPT 4: Search for the video by filename only (most common correct path) ---
        guard let path = Bundle.main.path(forResource: "LoadingRun", ofType: "mp4") else {
            // Added debugging output
            print("❌ ERROR: Video file 'BlackPantherRun.mp4' NOT found. Check Build Phases -> Copy Bundle Resources.")
            DispatchQueue.main.async { self.isFinished = true }
            return AVPlayerViewController()
        }
        
        // Success debugging output
        print("✅ SUCCESS: Video file path found at: \(path)")
        
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.showsPlaybackControls = false
        playerController.videoGravity = .resizeAspectFill
        
        // 2. Pass the AVPlayer instance to the Coordinator for looping control
        context.coordinator.player = player

        // 3. Add an observer to detect when the video finishes playing
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        // 4. Start playback
        player.play()
        return playerController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No updates necessary
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: VideoSplashView
        var player: AVPlayer?

        init(_ parent: VideoSplashView) {
            self.parent = parent
        }

        @objc func playerDidFinishPlaying(note: NSNotification) {
            
            // 1. Seek back to the start of the video
            self.player?.seek(to: .zero)
            
            // 2. Start playback again (loop)
            self.player?.play()
        }
    }
}
