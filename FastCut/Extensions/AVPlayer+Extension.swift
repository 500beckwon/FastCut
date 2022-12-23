//
//  Extension+AVPlayer.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
