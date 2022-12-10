//
//  VideoPlayViewController.swift
//  picple
//
//  Created by GNComms on 2021/11/02.
//  Copyright © 2021 Choi. All rights reserved.
//

import AVKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

extension VideoPlayViewController {
    @objc func cutAndPlayVideo() {
        player?.pause()
        indicator.startAnimating()
        backButton.isHidden = true
        sendVideoDircetoryButton.isHidden = true
//        guard let videoManager = videoManger else { return }
//        if MyProfileCheck.shared.videoSendDone == true {
//            if unityMode != .enterMyRoom {
//                MyProfileCheck.shared.videoSendDone = false
//                VideoRecodeManeger.shared.deleteVideoFile()
//            } else {
//                VideoRecodeManeger.shared.deleteVideoFile()
//            }
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //            videoManager.exportTrimmingVideo { [weak self] success in
            //                guard let self = self else { return }
            //                //MyProfileCheck.shared.videoSendDone = true
            //                print("동영상 유니티 전송 성공 = \(success)")
            //                self.sendMuteSignal(type: .muteCancel)
            //                DispatchQueue.main.async { [weak self] in
            //                    self?.backButton.isHidden = false
            //                    self?.sendVideoDircetoryButton.isHidden = false
            //                    self?.navigationController?.popToRootViewController(animated: true)
            //                }
            //            }
            //        }
        }
    }

    func playVideo() {
        playerLayer.removeFromSuperlayer()
        guard let videoItem = videoItem else { return }
        guard player == nil else { return }
        player = AVPlayer(playerItem: videoItem)
        player?.isMuted = false
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerView.layer.addSublayer(playerLayer)
        videoManger?.setAudio()
    }
}

///
public class VideoPlayViewController: UIViewController {
    var backButton = UIButton(type: .system)
    var playButton = UIButton(type: .system)
    var muteButton = UIButton(type: .system)
    var playerView = UIView()
    var scrollView = UIScrollView()
    var sendVideoDircetoryButton = UIButton(type: .system)
    var endtimeLabel = UILabel()

    var timeCutLabel = UILabel()
    var indicator = UIActivityIndicatorView()

    let disposeBag = DisposeBag()

    var playerLayer = AVPlayerLayer()
    var videoItem: AVPlayerItem?
    var player: AVPlayer?

    let saveListName = "TrimVideoLists"
    var currentTime: CMTime?
    var maxCutTime: CGFloat = 15
    lazy var fullWidth = screenWidth - 115
    //let fullWidth = screenWidth - 72
    var videoNavigationView = VideoNavigationView()

    var videoManger: VideoHelpManeger?
    var timeObserver: Any?
    var hideTimer: Timer?
    var videoCachingManeger = VideoCachingManeger()
    let videoCompressor = LightCompressor()
    var compression: Compression!

    var width: Constraint?
    var height: Constraint?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let videoItem = videoItem else { return }
        videoManger = VideoHelpManeger(videoItem: videoItem)
        videoNavigationView.asset = videoItem.asset
        insertUI()
        basicSetUI()
        anchorUI()
        buttinBindUI()
        resetHideTimer()
        playVideo()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
        
        videoManger?.videoPlayObservable(player: player, completion: { [weak self] currentTime, currentLeft in
            self?.endtimeLabel.text = currentTime
            self?.videoNavigationView.progressIndicatorLeft?.update(offset: currentLeft)
        }, reply: { [weak self] maxCutTime, currentTime in
            self?.player?.pause()
            let currentTimeInSecondsPlus10 = CMTimeGetSeconds(currentTime).advanced(by: -maxCutTime)
            let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus10), timescale: 1)
            self?.player?.seek(to: seekTime)
            self?.videoNavigationView.progressIndicatorLeft?.update(offset: 0)
            self?.player?.play()
            return
        })
        
        do {
            //try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            
            //try AVAudioSession.sharedInstance().setMode(.moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let e {
            print(e.localizedDescription, "asdfasfafdsf")
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        videoManger?.deleteVideoCache(navgationView: videoNavigationView, player: player)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard playerLayer.frame == .zero else { return }
        playerLayer.frame = playerView.bounds
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    func buttinBindUI() {
        backButton
            .rx
            .tap
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.player?.pause()
                NotificationCenter.default.post(name: NSNotification.Name("completeReadyRoom"), object: nil)
               // self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
    }

    /// 동영상 제어 UI isHidden 타이머 초기화
    func resetHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                         target: self,
                                         selector: #selector(hideControls),
                                         userInfo: nil,
                                         repeats: false)
    }

    /// 화면 탭 시 동영상 제어 UI isHidden 반대로 반영
    @objc func toggleControls() {
        playButton.isHidden = !playButton.isHidden
        resetHideTimer()
    }

    /// 동영상 제어 UI isHidden = true
    @objc func hideControls() {
        playButton.isHidden = true
    }

    /// 일시정지, 일시정지 해제
    /// - Parameter sender: 재생버튼
    @objc func playPauseTapped(_ sender: UIButton) {
        guard let player = player else { return }
        if !player.isPlaying {
            guard let videoItem = videoItem else { return }
            if player.currentTime() == videoItem.duration {
                let seekTime = CMTime(value: CMTimeValue(0), timescale: 600)
                player.seek(to: seekTime)
            } else {
            }
            player.play()
        } else {
            player.pause()
        }
        sender.isSelected = !sender.isSelected
    }
    
    @objc func muteButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        player?.isMuted = sender.isSelected
        videoManger?.setAudio(sender.isSelected)
    }

    func getVideoFrameSize(asset: AVURLAsset) -> String {
        guard let track = asset.tracks(withMediaType: .video).first else { return "square" }
        let size = track.naturalSize.applying(track.preferredTransform)
        if size.width > size.height {
            return "horizontal"
        } else if size.width < size.height {
            return "vertical"
        } else {
            return "square"
        }
    }
}

/// UI Layer 설정
extension VideoPlayViewController: VideoNavigationViewDelegate {
    func didSelectedPlayTapped(_ sender: UIButton) {
        guard let player = player else { return }
        if !player.isPlaying {
            guard let videoItem = videoItem else { return }
            if player.currentTime() == videoItem.duration {
                let seekTime = CMTime(value: CMTimeValue(0), timescale: 600)
                player.seek(to: seekTime)
            } else {
            }
            player.play()
        } else {
            player.pause()
        }
        sender.isSelected = !sender.isSelected
        resetHideTimer()
    }
    
    func didChangeCutMaxTime(cutTime: Double) {
        let _cutTime = trunc(10 * cutTime) / 10
        videoManger?.maxCutTime = _cutTime
    }

    func indicatorDidChangePosition(videoNavigationView: VideoNavigationView, position: Float64, state: Bool) {
        player?.pause()
        guard let _asset = videoItem?.asset,
              let videoManger = videoManger,
              let currentTime = player?.currentItem?.duration.seconds else { return }
        
        // start end Indicator 위치값으로 산정해야함
        let startSecond = videoManger.startTimeSeconds
        let endSecond = videoManger.endTimeSeconds
        let currentSeconds = CMTime(seconds: startSecond + position, preferredTimescale: 600)
        videoManger.currentTime = currentSeconds
        player?.seek(to: currentSeconds, toleranceBefore: .zero, toleranceAfter: .zero)
        if state == true {
            player?.play()
        }
    }

    func videoScrollViewDidEndDecelerating(scrollView: UIScrollView) {
        endtimeLabel.isHidden = false
        player?.play()
    }

    func videoScrollViewDidEndDragging(scrollView: UIScrollView) {
        endtimeLabel.isHidden = false
        player?.play()
    }

    func didChangeTimeValue(videoRangeSlider: VideoNavigationView, startTime: Float64, endTime: Float64) {
        player?.pause()
        endtimeLabel.isHidden = true
        guard let videoManeger = videoManger else { return }
        let position = videoRangeSlider.collectionView.contentOffset.x
        let count = videoNavigationView._displayVideoframeImages.count
        let currenttime = videoManeger.sliderScrollSetValue(position: position, count: count, startTime: startTime)
        player?.seek(to: currenttime, toleranceBefore: .zero, toleranceAfter: .zero)
        player?.play()
    }

    func videoScrollViewDidScroll(scrollView: UIScrollView) {
        player?.pause()
        guard let videoManeger = videoManger else { return }
        let position = scrollView.contentOffset.x
        let count = videoNavigationView._displayVideoframeImages.count
        let currenttime = videoManeger.sliderScrollSetValue(position: position, count: count)
        player?.seek(to: currenttime)
    }
}

/*

 func didChangeTimeValue(videoRangeSlider: VideoNavigationView, startTime: Float64, endTime: Float64) {
     player?.pause()
     guard let videoManeger = videoManger else { return }

        let itemWidth = _asset.duration.seconds < 15 ? fullWidth / 5 : fullWidth / 5.5
        let videoTrackLength = itemWidth * CGFloat(videoNavigationView._displayVideoframeImages.count)

     let position = videoRangeSlider.collectionView.contentOffset.x
        let percent = position / CGFloat(videoTrackLength)
        var currentSecond: Float64 = _asset.duration.seconds * Double(percent)

        currentSecond += startTime
        let endSecond = currentSecond + videoManeger.maxCutTime

        let currentTime = CMTime(seconds: currentSecond, preferredTimescale: 600)

        videoManeger.currentTime = currentTime
        videoManeger.startTimeSeconds = currentSecond
        videoManeger.endTimeSeconds = endSecond

        player?.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
        player?.play()
     let currenttime = videoManeger.sliderScrollSetValue(position: position, count: videoNavigationView._displayVideoframeImages.count, startTime: startTime)
     player?.seek(to: currenttime, toleranceBefore: .zero, toleranceAfter: .zero)
     player?.play()
 }

 func videoScrollViewDidScroll(scrollView: UIScrollView) {
     print("videoScrollViewDidScroll")
     player?.pause()
     guard let videoManeger = videoManger else { return }

     let itemWidth = _asset.duration.seconds < 15 ? fullWidth / 5 : fullWidth / 5.5
     let videoTrackLength = itemWidth * CGFloat(videoNavigationView._displayVideoframeImages.count)

     let position = scrollView.contentOffset.x
        let percent = position / CGFloat(videoTrackLength)
        var currentSecond: Float64 = _asset.duration.seconds * Double(percent)

        if scrollView.contentOffset.x < 0 {
            currentSecond = 0
        }

        currentSecond = trunc(currentSecond * 100) / 100

        let currentTime = CMTime(seconds: currentSecond, preferredTimescale: 600)

        videoManeger.currentTime = currentTime
        videoManeger.startTimeSeconds = currentSecond
        videoManeger.endTimeSeconds = currentSecond + videoManeger.maxCutTime

     player?.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
     let currenttime = videoManeger.sliderScrollSetValue(position: position, count: videoNavigationView._displayVideoframeImages.count)
     player?.seek(to: currenttime)

 }
 func getTrackStartCMTime(scrollView: UIScrollView, isPlay: Bool = false) {
     guard let videoManeger = videoManger else { return }
     player?.pause()
     videoNavigationView.progressIndicatorLeft?.update(offset: 0)
     guard let _asset = videoItem?.asset else {
         return
     }

     // length of video track
     let videoTrackLength = (fullWidth / 5.5) * CGFloat(videoNavigationView._displayVideoframeImages.count)
     var position = scrollView.contentOffset.x + fullWidth
     if scrollView.contentOffset.x <= 0 {
         position = 0
     }
     let percent = position / CGFloat(videoTrackLength)
     var currentSecond: Float64 = _asset.duration.seconds * Double(percent)

     if scrollView.contentOffset.x < 0 {
         currentSecond = 0
     }

     currentSecond = max(currentSecond - videoManeger.maxCutTime, 0)
     currentSecond = min(currentSecond, _asset.duration.seconds)
     currentSecond = trunc(currentSecond * 10) / 10

     let currentTime = CMTimeMakeWithSeconds(currentSecond, preferredTimescale: _asset.duration.timescale)
     // self.currentTime = currentTime
     //  videoManeger.currentTime = currentTime
     videoManeger.currentTime = currentTime
     player?.seek(to: currentTime)

     //  if isPlay {
     // player?.play()
     // }
 }
 private func thumbnailCount(inView: UIView) -> Int {
     var num: Double = 0

     //   DispatchQueue.main.async {
     print(inView.frame.size.width, inView.frame.size.height)
     num = Double(inView.frame.size.width) / Double(inView.frame.size.height)
     //   }

     return Int(trunc(num))
 }

 private func addImagesToView(images: [UIImage], view: UIView) {
     thumbnailViews.removeAll()
     var xPos: CGFloat = 0.0
     var width: CGFloat = 0.0
     for image in images {
         DispatchQueue.main.async {
             if xPos + view.frame.size.height < view.frame.width {
                 width = view.frame.size.height
             } else {
                 width = view.frame.size.width - xPos
             }

             let imageView = UIImageView(image: image)
             imageView.alpha = 0
             imageView.contentMode = .scaleAspectFill
             imageView.clipsToBounds = true
             imageView.frame = CGRect(x: xPos,
                                      y: 0.0,
                                      width: width,
                                      height: view.frame.size.height)
             self.thumbnailViews.append(imageView)

             view.addSubview(imageView)
             UIView.animate(withDuration: 0.2, animations: { () -> Void in
                 imageView.alpha = 1.0
             })
             view.sendSubviewToBack(imageView)
             xPos = xPos + view.frame.size.height
         }
     }
 }

 func thumbnailFromVideo(videoUrl: URL, time: CMTime) -> UIImage {
     let asset: AVAsset = AVAsset(url: videoUrl) as AVAsset
     let imgGenerator = AVAssetImageGenerator(asset: asset)
     imgGenerator.appliesPreferredTrackTransform = true
     do {
         let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
         let uiImage = UIImage(cgImage: cgImage)
         return uiImage
     } catch {
     }
     return UIImage()
 }

 func updateThumbnails(view: UIView, videoURL: URL, duration: Float64) -> [UIImageView] {
     var thumbnails = [UIImage]()
     var offset: Float64 = 0

     for view in thumbnailViews {
         DispatchQueue.main.async {
             view.removeFromSuperview()
         }
     }

     let imagesCount = thumbnailCount(inView: view)
     for i in 0 ..< imagesCount {
         let thumbnail = thumbnailFromVideo(videoUrl: videoURL,
                                            time: CMTimeMake(value: Int64(offset), timescale: 1))
         offset = Float64(i) * (duration / Float64(imagesCount))
         print(offset, "offsetoffset")
         thumbnails.append(thumbnail)
     }
     addImagesToView(images: thumbnails, view: view)
     return thumbnailViews
 }
  compression = videoCompressor.compressVideo(
                                  source: source,
                                  destination: _videoSavePath,
                                  quality: .high,
                                  isMinBitRateEnabled: true,
                                  keepOriginalResolution: false,
                                  progressQueue: .main,
                                  progressHandler: { progress in
                                      // progress
                                      print(progress, "CompressionCompression")
                                  },
                                  completion: {[weak self] result in
                                      guard let `self` = self else { return }

                                      switch result {
                                      case .onSuccess(let path):
                                          // success
                                                   print(path)

                                          if let data = try? Data(contentsOf: path) {
                                              let now = DateCalculation.shared.getDetailDate(today: Date())
                                              NetworkService
                                                  .shared
                                                  .uploadImportVideoGetURL(id: self.myID, time: now) { s3URL, _ in
                                                  if let s3URLs = s3URL?.url {
                                                      NetworkService
                                                          .shared
                                                          .videoUpload(s3URLs, videoData: data) { result, error in
                                                          //∂ç    let sizeCheck = self.getVideoFrameSize(asset: urlAsset)
                                                              print(result, error)
                                                            //  guard let sendURL = NSString(string: sendVideoURLS[0]).utf8String,
                                                              //      let uploadURL = NSString(string: s3URLs).utf8String else {return }
                                                              print(data, "adsfasdfasdfasdfsadfasdf", s3URLs)
                                                            //  videoSend(sendURL, uploadURL, sendSize)
                                                           //   RootHideCheck.shared.rootHideMode = .photoCancel
                                                            //  self.navigationController?.popViewControllers(viewsToPop: 2)
                                                      }
                                                  }
                                              }

 //                                                        DispatchQueue.main.async {
 //
 //                                                        self.player = AVPlayer(url: path)
 //                                                        self.player?.isMuted = false
 //
 //                                                        self.playerLayer = AVPlayerLayer(player: self.player)
 //
 //                                                        self.playerLayer.videoGravity = .resizeAspectFill
 //                                                        self.playerLayer.frame = self.playerView.bounds
 //                                                        self.playerView.layer.addSublayer(self.playerLayer)
 //                                                        self.playerView.layoutIfNeeded()
 //                                                        self.player?.play()
 //                                                        }
                                          }
                                      case .onStart:
                                          print("onStartonStart")
                                          // when compression starts

                                      case .onFailure(let error):
                                          // failure error
                                          print("onFailureonFailure", error)
                                      case .onCancelled:
                                          print("onCancelledonCancelled")
                                          // if cancelled
                                      }
                                  }
   )
 extension VideoPlayViewController: ABVideoRangeSliderDelegate {
     public func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
         print("startTime = \(startTime)")
         print("endTime = \(endTime)")
         cutStartTime = startTime
         cutEndTime = endTime
     }

     public func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
         print("position of indicator: \(position)")
         indicatorTime = position
         //     player?.pause()
         //     guard let duration = player?.currentItem?.duration else { return }
         //     let value = Float64(position) * CMTimeGetSeconds(duration)
         let seekTime = CMTime(value: CMTimeValue(position), timescale: 1)
         player?.seek(to: seekTime)
     }

 //                self.player?.pause()
 //                self.timeObserver = nil
 //                self.hideTimer?.invalidate()
 //                print(self.videoItem?.asset, "bindUIbindUIbindUI", self.videoItem)
 //                guard let asset = self.videoItem?.asset else { return }
 //                guard let track = asset.tracks(withMediaType: .video).first else { return }
 //
 //                let fileManeger = FileManager.default
 //                let docmentURLS = fileManeger.urls(for: .documentDirectory, in: .userDomainMask).first
 //                let now = DateCalculation.shared.getDetailDate(today: Date())
 //                let directoryURL = docmentURLS?.appendingPathComponent("\(now)")
 //
 //                do {
 //                    try fileManeger.createDirectory(atPath: directoryURL?.path ?? "", withIntermediateDirectories: false, attributes: nil)
 //                } catch let e {
 //                    print(e.localizedDescription)
 //                }
 //
 //                let videoSavePath = directoryURL?.appendingPathComponent("\(now).mp4")
 //
 //                guard let _videoSavePath = videoSavePath else {
 //                    print("_videoSavePath success1")
 //                    return
 //                }
 //
 //                if let urlAsset = asset as? AVURLAsset {
 //                    print(urlAsset.url, "asdfasdfa")
 //                    let sizeCheck = self.getVideoFrameSize(asset: urlAsset)
 //                    let avAsset = AVURLAsset(url: urlAsset.url)
 //                    let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
 //                    exportSession?.outputURL = urlAsset.url
 //                    exportSession?.outputFileType = .mp4
 //                    if let mp4URL = exportSession?.outputURL, let data = try? Data(contentsOf: mp4URL) {
 //                        print(_videoSavePath)
 //
 //                        sendVideoURLS.append("\(_videoSavePath)")
 //                        do {
 //                            try data.write(to: _videoSavePath)
                 ////                            if let videoSend = VideoManager._sharedInstance().videoHandler {
                 ////                                guard let sendURL = NSString(string: "\(_videoSavePath)").utf8String,
                 ////                                      let sendSize = NSString(string: sizeCheck).utf8String else { return }
                 ////                                if let _ = try? Data(contentsOf: _videoSavePath) {
                 ////                                    //    videoSend(sendURL, sendSize)
                 ////                                    self.navigationController?.popViewControllers(viewsToPop: 2)
                 ////                                }
                 ////                            }
 //                        } catch let error as NSError {
 //                            print("Error creating File : \(error.localizedDescription)")
 //                        }
 //                    }
 //
 //                } else {
 //                    if !sendVideoURLS.isEmpty {
 //                        if let a = asset.tracks[0].asset as? AVURLAsset {
 //                            print(a, "!sendVideoURLS.isEmpty")
 //                        } else {
 //                            if let a = asset.tracks[1].asset as? AVURLAsset {
 //                                print(a, "!sendVideoURLS.isEmpty")
 //                            }
 //                        }
 //                        print(asset.tracks, "asdfasdfasdf", asset.tracks.count)
 //                        let filepath = sendVideoURLS[0]
 //                        print(filepath, "자른경로", sendVideoURLS.count)
 //                        let sizeCheck = "horizontal"
 //                        if let videoSend = VideoManager._sharedInstance().videoReHandler {
 //                            guard let pathURL = URL(string: filepath),
 //
 //                                  let sendSize = NSString(string: sizeCheck).utf8String else { return }
 //                            print(pathURL, "전송할 로컬NSString", filepath)
 //                            if let videoData = try? Data(contentsOf: pathURL) {
 //                                let now = DateCalculation.shared.getDetailDate(today: Date())
 //                                NetworkService
 //                                    .shared
 //                                    .uploadImportVideoGetURL(id: self.myID, time: now) { s3URL, _ in
 //                                        if let s3URLs = s3URL?.url {
 //                                            NetworkService
 //                                                .shared
 //                                                .videoUpload(s3URLs, videoData: videoData) { result, error in
 //                                                    // ∂ç    let sizeCheck = self.getVideoFrameSize(asset: urlAsset)
 //                                                    print(result, error, sendVideoURLS[0])
 //                                                    guard let sendURL = NSString(string: sendVideoURLS[0]).utf8String,
 //                                                          let uploadURL = NSString(string: s3URLs).utf8String else { return }
 //                                                    print(videoData, "adsfasdfasdfasdfsadfasdf", s3URLs)
 //                                                    videoSend(sendURL, uploadURL, sendSize)
 //                                                    RootHideCheck.shared.rootHideMode = .photoCancel
 //                                                    self.navigationController?.popViewControllers(viewsToPop: 2)
 //                                                }
 //                                        }
 //                                    }
 //
 //                            } else {
 //                                print("try TLfvo")
 //                            }
 //                        }
                 //        }
                 //     }

 //            print(trimVideo.tracks(withMediaType: .video).first?.naturalSize, "스케일 조정 결과", cutStartTime, cutEndTime)
 //            let a = AVPlayerItem(asset: trimVideo)
 //            print(a, "애에이ㅇㅊㅊ ", a.asset.tracks(withMediaType: .video).first?.naturalSize)
 //            player?.replaceCurrentItem(with: a)
 //            player?.play()
 //        } else {
 //            print("스케일 조정 결과x", cutStartTime, cutEndTime)
 //        }
         //  if let trimVideo = try? asset.assetByTrimming(startTime: startTime, endTime: endTime) { }
         // print(trimVideo.duration, trimVideo.duration.seconds, "assetByTrimming = success")
 //            if let newITem = trimVideo as? AVURLAsset {
 //                print(newITem, "캐싱1")
 //            } else {
 //                print("캐싱실패1")
 //                if let newItem = trimVideo.tracks.first as? AVURLAsset {
 //                    print(newItem, "캐싱1")
 //                } else {
 //                    print("캐싱실패2")
 //                }
 //            }
 //            player?.pause()
         // let item = AVPlayerItem(asset: trimVideo)
         //    print(item)
         // player?.replaceCurrentItem(with: item)
 //
 //            playerLayer.removeFromSuperlayer()
 //            let a = AVPlayerItem(asset: trimVideo)
 //
 //            // let player = AVPlayer(playerItem: a)
 //            print(a, "에이에이에이", _videoSavePath, a.asset, a.status)
 //            let e = AVAssetExportSession(asset: trimVideo, presetName: AVAssetExportPresetHighestQuality)
 //            e?.outputURL = _videoSavePath
 //            e?.outputFileType = .mp4
 //            e?.exportAsynchronously {
 //                print(e?.status)
 //                switch e?.status {
 //                case .completed:
 //                    print("eexportSession.status = completed")
 //                    if let mp4URL = e?.outputURL, let _ = try? Data(contentsOf: mp4URL) {
 //                        // self.player?.pause()
 //                        sendVideoURLS.append("\(_videoSavePath)")
 //                        //  self.videoItem = AVPlayerItem(url: mp4URL)
 //                        // self.player = AVPlayer(d)
 //                        // self.playVideo()
 //                    }
 //                case .cancelled:    print("eexportSession.status = cancelled")
 //                case .failed:        print("eexportSession.status = failed")
 //                case .exporting:    print("eexportSession.status = exporting")
 //                case .waiting:      print("exportSession.status = waiting")
 //                default:print("eexportSession.status = completed")
 //                }
 //            }
         //
         //   } else {
         //      print("assetByTrimming = false")
         //  }
 \
 ]//                            let newDirectoryURL = docmentURLS.appendingPathComponent(self.saveListName)
 //                            do {
 //                                try fileManeger.createDirectory(atPath: newDirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
 //                            } catch let e {
 //                                print(e.localizedDescription, "ㅁㄴㅇㄹㅁㄴㅇㄹㅁㄴㅇㄹ")
 //                            }
  */
