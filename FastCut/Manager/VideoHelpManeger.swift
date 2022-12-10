//
//  VideoHelpManeger.swift
//  picple
//
//  Created by GNComms on 2022/01/07.
//  Copyright © 2022 Choi. All rights reserved.
//

import AVFoundation
import UIKit


protocol VideoManagerDelegate {
    func selectVideoRemove(specific urlString: String)
    func sendVideoPath(userID: String, videoSavePath: String, sizeCheck: String, mute: Bool, angle: Double, size: CGSize, completion: @escaping () -> Void)
}

extension VideoManagerDelegate {
    func selectVideoRemove(specific urlString: String = "") {
     //   VideoRecodeManeger.shared.deleteVideoFile()
//        if urlString.isEmpty {
//            if !sendVideoURLS.isEmpty {
//                for i in sendVideoURLS {
//                    print("지울 비디오 경로 = \(i)")
//                    deleteVideoPathItem(urlString: i)
//                }
//            }
//        } else {
        deleteVideoPathItem(urlString: urlString)
//        }
    }

    func sendVideoPath(userID: String, videoSavePath: String, sizeCheck: String, mute: Bool, angle: Double, size: CGSize, completion: @escaping () -> Void) {
//        if let videoSend = VideoManager._sharedInstance().videoReHandler {
//            let videoUploadURL = "\(DateCalculation.shared.getDetailDate(today: Date())).mp4"
//            VideoRecodeManeger.shared.saveVideoInfo(videoPath: videoSavePath, videoName: videoUploadURL, saveDate: "\(Date())") { saveResult in
//                print(saveResult, "비디오 정보 저장 결과", "비디오 이름 = \(videoUploadURL)")
//            }
//
//            DispatchQueue.main.async {
//                guard let sendURL = NSString(string: "\(videoSavePath)").utf8String,
//                      let uploadURL = NSString(string: "\(videoUploadURL)").utf8String,
//                //      let sendSize = NSString(string: sizeCheck).utf8String,
//                      let soundOff = NSString(string: "\(!mute)").utf8String,
//                      let rotate = NSString(string: "\(angle)").utf8String else { return }
//                videoSend(sendURL, uploadURL, soundOff, rotate)
//                if UnityModeTrack.shared.unityMode != . enterMyRoom {
//                    UnityModeTrack.shared.unityMode = .makingProcess
//                }
                completion()
       //     }
     //   }//
    }

    func deleteVideoPathItem(urlString: String = "") {
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            print(data, "지울 비디오 ", urlString)
            do {
                try FileManager.default.removeItem(at: url)
            } catch let e {
                print("""
                  비디오 삭제 실패
                  \(e.localizedDescription)
                """)
            }
        }
    }
}

class VideoHelpManeger: VideoManagerDelegate, ScreenSize {

    var videoItem: AVPlayerItem

    /// Edit 시간
    var maxCutTime: CGFloat = 15

    /// 현재 재생 시각
    var currentTime: CMTime = .zero

    /// 총 재생 시간
    var fullDuration: CGFloat = 0

    /// 재생 시작점
    var startTimeSeconds: CGFloat = 0

    /// 재생 마지막지점
    var endTimeSeconds: CGFloat = 0

    // let fullWidth = screenWidth - 72
    lazy var fullWidth = screenWidth - 115

    // 음소거 false = 무음, true = 유음
    var mute = false

    var videoSize = "square"

    let saveListName = "TrimVideoLists"

    let videoCompressor = LightCompressor()
    var compression: Compression?
    var videoSaveManeger = VideoRecodeManeger()

    init(videoItem: AVPlayerItem) {
        self.videoItem = videoItem
        let durationSeconds = videoItem.duration.seconds
        fullDuration = trunc(100 * durationSeconds) / 100
        maxCutTime = durationSeconds < 15 ? durationSeconds : 15
        endTimeSeconds = maxCutTime
        videoSize = getVideoFrameSize(videoItem: videoItem)
    }

    func sliderScrollSetValue(position: CGFloat, count: Int, startTime: Float64? = nil) -> CMTime {
        let asset = videoItem.asset
        let itemWidth = asset.duration.seconds < 15 ? fullWidth / 5 : fullWidth / 5.5
        let videoTrackLength = itemWidth * CGFloat(count)

        let percent = position / CGFloat(videoTrackLength)
        var currentSecond: Float64 = asset.duration.seconds * Double(percent)

        if position < 0 {
            currentSecond = 0
        }

        currentSecond = trunc(currentSecond * 100) / 100
        if let startTime = startTime {
            currentSecond += startTime
        }
        let endSecond = currentSecond + maxCutTime
        let currentTime = CMTime(seconds: currentSecond, preferredTimescale: 600)

        self.currentTime = currentTime
        startTimeSeconds = currentSecond
        endTimeSeconds = endSecond

        return currentTime
    }

    func getVideoFrameSize(videoItem: AVPlayerItem) -> String {
        guard let track = videoItem.asset.tracks(withMediaType: .video).first else { return "square" }
        let size = track.naturalSize.applying(track.preferredTransform)
        print(size, "getVideoFrameSize")
        if size.width > size.height {
            return "horizontal"
        } else if size.width < size.height {
            return "vertical"
        } else {
            return "square"
        }
    }

    func setAudio(_ muteOff: Bool = false) {
        mute = muteOff
        if let _ = videoItem.asset as? AVURLAsset {
//            do {
//                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
//                try AVAudioSession.sharedInstance().setMode(.moviePlayback)
//                try AVAudioSession.sharedInstance().setActive(true)
//            } catch let e {
//                print(e.localizedDescription)
//            }
        }
    }

    func getSavePathDocument() -> URL? {
        let fileManeger = FileManager.default
        guard let docmentURLS = fileManeger.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let directoryURL = docmentURLS.appendingPathComponent(saveListName)
        do {
            try fileManeger.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: false, attributes: nil)
        } catch let e {
            print(e.localizedDescription, "아하핳")
        }
        return directoryURL
    }

    func deleteVideoCache(navgationView: VideoNavigationView, player: AVPlayer?) {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        navgationView._displayKeyframeImages.removeAll()
        navgationView._displayVideoframeImages.removeAll()
    }

    func videoPlayObservable(player: AVPlayer?, completion: @escaping (_ currentTime: String, _ currentLeft: CGFloat) -> Void, reply: @escaping (_ maxCutTime: CGFloat, _ currentTime: CMTime) -> Void) {
        let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak player] _ in
            guard let player = player,
                  let currentItem = player.currentItem else { return }
            let currentTime = player.currentTime()
            let duration = currentItem.duration
            let currentTimeInSeconds = trunc(CMTimeGetSeconds(currentTime) * 100) / 100
            let customCurrentTime = self.currentTime.seconds
            if player.isPlaying == false {
                print("dsfasdfadfa", currentTimeInSeconds, customCurrentTime)
            } else {
                if CMTIME_IS_INVALID(duration) {
                    return
                }

                let fullWidth = self.screenWidth - 120
                var currentLeft: CGFloat = 0

                let startSecond = self.startTimeSeconds
                let currentSecond = trunc(CMTimeGetSeconds(currentTime) * 100) / 100

                let maxSecond = (startSecond + self.maxCutTime)

                var value = ((currentSecond - startSecond) / 15)
                if duration.seconds < 15 {
                    value = ((currentSecond - startSecond) / duration.seconds)
                }
                currentLeft = trunc(value * fullWidth)

                if currentLeft < 0 {
                    currentLeft = 0
                }

                if trunc(currentSecond * 10) / 10 == (trunc((startSecond + self.maxCutTime) * 10.0) / 10) || currentSecond == maxSecond {
                    reply(self.maxCutTime, currentTime)
                } else {
                }

                // let totalTimeInSeconds = CMTimeGetSeconds(duration)
                // let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds
                let remainingTimeInSeconds = currentTimeInSeconds

                let mins = remainingTimeInSeconds / 60
                let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
                let timeformatter = NumberFormatter()
                timeformatter.minimumIntegerDigits = 2
                timeformatter.minimumFractionDigits = 0
                timeformatter.roundingMode = .down
                guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                    return
                }
                completion("\(minsStr):\(secsStr)", currentLeft)
            }

        })
    }
}

extension VideoHelpManeger {
    func getEditTimeRange() -> (startTime: CMTime, endTime: CMTime) {
        let startCutSeconds = startTimeSeconds
        let endCutSeocnds = endTimeSeconds
        let startTime = CMTime(seconds: startCutSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let endTime = CMTime(seconds: endCutSeocnds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        return (startTime, endTime)
    }

    func getVideoNatureSize() -> CGSize {
        guard let size = videoItem.asset.tracks(withMediaType: .video).first?.naturalSize else { return .zero }
        return size
    }

    func getTrimmingVideo() -> AVAsset {
        
        let timeRange = getEditTimeRange()
        let asset = videoItem.asset
        
        do {
            let trimVideo = try asset.resizeAsset(startTime: timeRange.startTime,
                                                  endTime: timeRange.endTime,
                                                  naturalSizes: getVideoNatureSize(),
                                                  mute: mute)
            
            return trimVideo
        } catch let e {
            print(e.localizedDescription)
        }
        return asset
    }

    // AVAssetExportPresetLowQuality
    // AVAssetExportPresetMediumQuality
    // AVAssetExportPreset960x540
    // AVAssetExportPresetHighestQuality
    // AVAssetExportPreset1920x1080

    func exportTrimmingVideo(completion: @escaping (_ success: Bool) -> Void) {
        let video = getTrimmingVideo()
        let exporter = AVAssetExportSession(asset: video, presetName: AVAssetExportPreset1920x1080)
        let outputFileName = DateCalculation.shared.getDetailDate(today: Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + 1))
        let basicURL = getSavePathDocument()
        let videoSavePath = basicURL?.appendingPathComponent("\(outputFileName)").appendingPathExtension("mp4")
        exporter?.outputFileType = .mp4
        
        exporter?.outputURL = videoSavePath
        exporter?.exportAsynchronously { [weak self] in
            switch exporter?.status {
            case .completed:
                if let outputURL = exporter?.outputURL, let trimVideoData = try? Data(contentsOf: outputURL) {
                    let newNow = DateCalculation.shared.getDetailDate(today: Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + 1))
                    if trimVideoData.getDataMegaCount() > 2 {
                        guard let compressURL = basicURL?.appendingPathComponent(newNow).appendingPathExtension("mp4") else { return }
                        self?.videoCompressiong(sourceURL: outputURL, compressURL: compressURL, completion: completion)
                    } else {
                        self?.smallVideoSave(videoSavePath: outputURL, videoData: trimVideoData, completion: completion)
                    }
                }
            default:
                completion(false)
                print("""
                    비디오 익스포트 실패
                    \(exporter?.status.rawValue as Any)
                """)
            }
        }
    }

    func smallVideoSave(videoSavePath: URL, videoData: Data, completion: @escaping (_ success: Bool) -> Void) {
       
        var success = true
        do {
            try videoData.write(to: videoSavePath)
        } catch let e {
            success = false
            print(e.localizedDescription, "스몰스몰")
        }
        if success == true {
            let sizeInfo = getRotate(url: videoSavePath)
            sendVideoPath(userID: "", videoSavePath: "\(videoSavePath)", sizeCheck: videoSize, mute: mute, angle: sizeInfo.angle, size: sizeInfo.size) {
                completion(true)
            }
        } else {
            completion(success)
        }
    }
    
    func getRotate(url: URL) -> (angle:Double,size: CGSize) {
        //let asset = AVAsset(url: url).tracks
        let asset = videoItem.asset.tracks
        print(asset)
        var angle: Double = 0
        var size = CGSize(width: 0, height: 0)
        asset.forEach { track in
            if track.mediaType == .video {
                let rotation = atan2(track.preferredTransform.b, track.preferredTransform.a)
                angle = rotation
                size = track.naturalSize
            }
        }
        return (-angle, size)
    }

    func videoCompressiong(sourceURL: URL, compressURL: URL, completion: @escaping (_ success: Bool) -> Void) {
        compression = videoCompressor
            .compressVideo(source: sourceURL,
                           destination: compressURL,
                           quality: .medium,
                           isMinBitRateEnabled: true,
                           keepOriginalResolution: false,
                           progressQueue: .main,
                           progressHandler: { progress in
                               print("압축 진행 상황 = ", progress)
                           }, completion: { [weak self] result in
                               guard let self = self else { return }
                               switch result {
                               case let .onSuccess(path):
                                   let data = try? Data(contentsOf: path)
                                   print("onSuccess = ", path, compressURL, sourceURL, data?.getDataMegaCount())
                                   let sizeInfo = self.getRotate(url: sourceURL)
                                  
                                   self.sendVideoPath(userID: "", videoSavePath: "\(compressURL)", sizeCheck: self.videoSize, mute: self.mute, angle: sizeInfo.angle, size: sizeInfo.size) {
                                       completion(true)
                                   }
                                   self.selectVideoRemove(specific: "\(sourceURL)")
                               
                               case .onStart:
                                   print("onStartonStart")
                               case .onFailure, .onCancelled:
                                   // failure error
                                   print("onFailureonFailure = ")
                                   completion(false)
                               }
                           })
    }
}

/*
 print("""

       clourserTime         = \(clourserTime)
       playerState          = \(player?.isPlaying)
       playerCurrentSeconds = \(currentTimeInSeconds)
       currentTime          = \(self.currentTime.seconds)
       startSecond          = \(startSecond)
       currentSecond        = \(currentSecond)
       value                = \(value)
       maxSecond            =  \(maxSecond)
       fullDuration         = \(self.fullDuration)
       currentLeft          = \(currentLeft)

 """)
 do {
     try? FileManager.default.removeItem(atPath: "file:///var/mobile/Containers/Data/Application/F7C38DBE-D075-498C-8E7C-E9E7BBFC4025/Documents/2021-11-16T16:33:37.045Z/2021-11-16T16:33:37.045Z.mp4")
 }

 /// 재생시각에 따른 슬라이더, 재생시간 레이블 업데이트
 func updateVideoPlayerSlider() {
     guard let currentTime = player?.currentTime() else { return }
     let currentTimeInSeconds = CMTimeGetSeconds(currentTime)

     // playSliderView.value = Float(currentTimeInSeconds)

     if let currentItem = player?.currentItem {
         let duration = currentItem.duration
         if CMTIME_IS_INVALID(duration) {
             return
         }

         let fullWidth = screenWidth - 75
         var currentLeft: CGFloat = 0

         let startTime = self.currentTime ?? .zero
         let startSecond = CMTimeGetSeconds(startTime)
         let currentSecond = CMTimeGetSeconds(currentTime)

         let maxSecond = (startSecond + maxCutTime)
         let value = ((currentSecond - startSecond) / maxCutTime)

         currentLeft = ceil(value * fullWidth)

         if currentLeft < 0 {
             currentLeft = 0
         }
         progressPercentage =  currentLeft/(screenWidth - 76)
         progressIndicatorLeft?.update(offset: currentLeft)
         if ceil(currentSecond) == (ceil(startSecond) + maxCutTime) {
             player?.pause()
             let currentTimeInSecondsPlus10 = CMTimeGetSeconds(currentTime).advanced(by: -maxCutTime)
             let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus10), timescale: 1)
             player?.seek(to: seekTime)
             progressIndicatorLeft?.update(offset: 0)
             player?.play()
             return
         }
         let totalTimeInSeconds = CMTimeGetSeconds(duration)
         let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds

         let mins = remainingTimeInSeconds / 60
         let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
         let timeformatter = NumberFormatter()
         timeformatter.minimumIntegerDigits = 2
         timeformatter.minimumFractionDigits = 0
         timeformatter.roundingMode = .down
         guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
             return
         }
         endtimeLabel.text = "\(minsStr):\(secsStr)"
     }
 }
 //        let now = DateCalculation.shared.getDetailDate(today: Date())
 //        guard let directoryURL = videoManager.getSavePathDocument() else { return }
 //
 //        let sizeCheck = videoManager.videoSize
 //        let videoSavePath = directoryURL.appendingPathComponent("\(now)").appendingPathExtension("mp4")
 //        guard let naturalSize = asset.tracks(withMediaType: .video).first?.naturalSize else { return }
 //        let startCutSeconds = videoManager.startTimeSeconds
 //        let endCutSeocnds = videoManager.endTimeSeconds
 //        let startTime = CMTime(seconds: startCutSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
 //        let endTime = CMTime(seconds: endCutSeocnds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
 //        print(videoSavePath, "videoSavePath")
 //        let timeRange = CMTimeRange(start: startTime, end: endTime)
 //
 //        if let trimVideo = try? asset.resizeAsset(startTime: startTime, endTime: endTime, naturalSizes: naturalSize) {
 //            print("eoeoeooeoeo")
 //            // AVAssetExportPresetLowQuality
 //            // AVAssetExportPresetMediumQuality
 //            // AVAssetExportPreset960x540
 //
 //            let e = AVAssetExportSession(asset: trimVideo, presetName: AVAssetExportPreset960x540)
 //        //    e?.videoComposition = videoComposition
 //            e?.outputURL = videoSavePath
 //            e?.outputFileType = .mp4
 //
 //            e?.exportAsynchronously {
 //                switch e?.status {
 //                case .completed:
 //                    if let mp4URL = e?.outputURL, let data = try? Data(contentsOf: mp4URL) {
 //                        if data.getDataMegaCount() > 2 {
 //                            let newNow = DateCalculation.shared.getDetailDate(today: Date(timeIntervalSinceNow: Date().timeIntervalSinceNow + 1))
 //
 //                            let newVideoSavePath = directoryURL.appendingPathComponent("\(newNow)").appendingPathExtension("mp4")
 //
 //                            self.compression = self.videoCompressor.compressVideo(source: mp4URL,
 //                                                                                  destination: newVideoSavePath,
 //                                                                                  quality: .very_low,
 //                                                                                  isMinBitRateEnabled: true,
 //                                                                                  keepOriginalResolution: false,
 //                                                                                  progressQueue: .main,
 //                                                                                  progressHandler: { progres in
 //                                                                                      print("압축 진행 상황 = ", progres)
 //
 //                                                                                  }, completion: { result in
 //                                                                                      switch result {
 //                                                                                      case let .onSuccess(path):
 //                                                                                          print("onSuccess = ", path)
 //                                                                                          self.videoManger?.sendVideoPath(videoSavePath: "\(path)", sizeCheck: sizeCheck) {
 //                                                                                              self.navigationController?.popToRootViewController(animated: true)
 //                                                                                          }
 //                                                                                          self.videoManger?.selectVideoRemove(specific: "\(mp4URL)")
 //                                                                                      case .onStart:
 //                                                                                          print("onStartonStart")
 //
 //                                                                                      case let .onFailure(error):
 //                                                                                          // failure error
 //                                                                                          print("onFailureonFailure", error)
 //                                                                                      case .onCancelled:
 //                                                                                          print("onCancelledonCancelled")
 //                                                                                          // if cancelled
 //                                                                                      }
 //                                                                                  })
 //                        } else {
 //                            do {
 //                                print("dkdkdkdkdkd")
 //                                try data.write(to: videoSavePath)
 //                            } catch let e {
 //                                print(e.localizedDescription, "저장저장")
 //                            }
 //                            self.videoManger?.sendVideoPath(videoSavePath: "\(videoSavePath)", sizeCheck: sizeCheck) {
 //                                self.navigationController?.popToRootViewController(animated: true)
 //                            }
 //                        }
 //                    }
 //                default: print("SaveFAULT", e?.status.rawValue)
 //                }
 //            }
 //        }
 */
