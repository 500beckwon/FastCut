//
//  VideoCachingManeger.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import AVKit

class VideoCachingManeger {
    typealias VideoSequenceOfImagesClosure = ([VideoFrameImage]) -> Void
    
    open func generateVideoSequenceOfTime(from asset: AVAsset, closure: @escaping VideoSequenceOfImagesClosure) {
        let second = Int(asset.duration.seconds)
        
        let maxCount = second / 3
        var requestedCount = 0
        //   var offset: Float64 = 0
        
        if second < 15 {
            requestedCount = 5
        } else {
            requestedCount = max(6, maxCount)
            print(requestedCount, maxCount, second * 2)
        }
        
        let spacing = asset.duration.seconds / Float64(requestedCount)
        var seconds: [Float64] = []
        
        for i in 0 ... requestedCount {
            seconds.append(Float64(i) * spacing)
        }
        
        generateVideoSequenceOfImages(from: asset, seconds: seconds, closure: closure)
    }
    
    open func generateVideoSequenceOfImages(from asset: AVAsset, seconds: [Float64], closure: @escaping VideoSequenceOfImagesClosure) {
        let times = seconds.map { CMTimeMakeWithSeconds($0, preferredTimescale: asset.duration.timescale) }
        var completionCount = 0
        var videoFrameImages = [VideoFrameImage]()
        for i in 0 ..< times.count {
            completionCount += 1
            let videoFrameImage = VideoFrameImage(requestedTime: times[i], actualTime: nil)
            videoFrameImages.append(videoFrameImage)
        }
        
        if completionCount == times.count {
            // sorted with Asc
            let sortedKeyframeImages = videoFrameImages.sorted {
                $0.requestedTime.seconds < $1.requestedTime.seconds
            }
            
            // perform on main queue
            DispatchQueue.main.async {
                closure(sortedKeyframeImages)
            }
        }
    }
    
    static func getSingleVideoSequenceOfImage(from asset: AVAsset, at time: CMTime) -> UIImage {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 75, height: 75)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            return image
        } catch let e {
            print("""
               비디오 이미지화 실패
              \(e.localizedDescription)
            """)
        }
        return UIImage()
    }
}
