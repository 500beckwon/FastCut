//
//  VideoPlayerManager.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/25.
//

import Foundation
import AVFoundation

final class VideoPlayerManager {
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var isPlay = false
    
    static let shared = VideoPlayerManager()
    
    var currentTime: CMTime {
        return player.currentItem?.currentTime() ?? .zero
    }
    
    var currentSecond: Double {
        return player.currentItem?.currentTime().seconds ?? .zero
    }
    
    var maxTimeText: String {
        return makeCMTimeText(duration: duration)
    }
    
    var currentTimeText: String {
        return makeCMTimeText(duration: currentSecond)
    }
    
    var duration: Double {
        player.currentItem?.duration.seconds ?? 0
    }
    
    func play() {
        player.play()
        
    }
    
    func makePlayer(item: AVPlayerItem) {
        player.replaceCurrentItem(with: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    func makeCurrentCMTime(percent: Double) {
        let second = percent * duration
        let cmTime = CMTime(seconds: second, preferredTimescale: 100)
        seek(with: cmTime)
    }
    
    func makeCMTimeText(duration: Double) -> String {
        let minute = Int(duration / 60)
        let second = Int(duration.truncatingRemainder(dividingBy: 60))
        let minuteText = minute < 10 ? "0\(minute)" : "\(minute)"
        let secondText = second < 10 ? "0\(second)" : "\(second)"
        let currentTimeText = "\(minuteText) : \(secondText)"
        return currentTimeText
    }
    
    func pause() {
        player.pause()
        isPlay = false
    }
    
    func seek(with time: CMTime) {
        player.seek(to: time)
    }
    
    func makeProgress() -> Float {
        let percent = currentSecond / duration
        return Float(percent)
    }
    
    func addPeriodicTimeObserver(forInterval: CMTime,
                                 queue: DispatchQueue? = .main,
                                 using: @escaping(CMTime) -> Void) -> Any {
        player.addPeriodicTimeObserver(forInterval: forInterval,
                                            queue: queue,
                                            using: using)
    }
}

