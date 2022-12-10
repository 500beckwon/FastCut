//
//  AVAsset+Extension.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import AVKit

extension AVAsset {
    func assetByTrimming(startTime: CMTime, endTime: CMTime, mute: Bool = false) throws -> AVAsset {
        let duration = CMTimeSubtract(endTime, startTime)
        let timeRange = CMTimeRange(start: startTime, duration: duration)

        let composition = AVMutableComposition()
       
        do {
            for track in tracks {
                if mute == true {
                    if track.mediaType == .audio {
                    } else {
                        let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                        // compositionTrack?.preferredTransform = track.preferredTransform
                        compositionTrack?.preferredTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
                    }
                } else {
                    let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)

                    compositionTrack?.preferredTransform = track.preferredTransform
                    try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
                }
            }
        } catch let error {
            throw TrimError("error during composition", underlyingError: error)
        }
        return composition
    }

    func resizeAsset(startTime: CMTime, endTime: CMTime, naturalSizes: CGSize, mute: Bool = false) throws -> AVAsset {
        let duration = CMTimeSubtract(endTime, startTime)
        let timeRange = CMTimeRange(start: startTime, duration: duration)

        let composition = AVMutableComposition()
       
        print(naturalSizes, "resizeAssetresizeAsset")
        //CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0) assetByTrimming

        //    guard let videoTrack = tracks(withMediaType: .video).first else { return self }
        //    print(videoTrack.estimatedDataRate, "videoTrack.estimatedDataRate")

        // let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        // layerInstruction.setTransform(videoAssetTrack.preferredTransform, at: kCMTimeZero)
        // composition.renderSize = CGSize(width: naturalSizes.width * 0.7, height: naturalSizes.height * 0.7)

        do {
            for track in tracks {
                if mute == true {
                    if track.mediaType == .audio {
                    } else {
                        let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                        // compositionTrack?.preferredTransform = track.preferredTransform
                        compositionTrack?.preferredTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
                    }
                } else {
                    let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                    compositionTrack?.preferredTransform = track.preferredTransform

                    try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
                }
            }
        } catch let error {
            throw TrimError("error during composition", underlyingError: error)
        }
        
        return composition
    }
 
}



