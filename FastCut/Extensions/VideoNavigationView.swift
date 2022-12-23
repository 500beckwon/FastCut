//
//  VideoNavigationView.swift
//  picple
//
//  Created by GNComms on 2022/01/05.
//  Copyright © 2022 Choi. All rights reserved.
//

import AVFoundation
import Foundation
import SnapKit
import UIKit

protocol VideoNavigationViewDelegate {
    func didSelectedPlayTapped(_ sender: UIButton)
    func videoScrollViewDidScroll(scrollView: UIScrollView)
    func videoScrollViewDidEndDragging(scrollView: UIScrollView)
    func videoScrollViewDidEndDecelerating(scrollView: UIScrollView)

    func didChangeCutMaxTime(cutTime: Double)
    func indicatorDidChangePosition(videoNavigationView: VideoNavigationView, position: Float64, state: Bool)
    func didChangeTimeValue(videoRangeSlider: VideoNavigationView, startTime: Float64, endTime: Float64)
}

final class VideoNavigationView: UIView {
    var delegate: VideoNavigationViewDelegate?
    var _displayKeyframeImages: [KeyframeImage] = []
    var _displayVideoframeImages: [VideoFrameImage] = []

    var asset: AVAsset? {
        didSet {
            let seconds = asset?.duration.seconds ?? 0
            let cutAbleSeconds = seconds < 15 ? seconds : 15.0
            videoDuration = seconds
            maxCutTimeLabel.text = "\(trunc(cutAbleSeconds * 10)/10)초"
            duration = cutAbleSeconds
            getVideoSequenceOfTime()
        }
    }

    var maxCutTimeLabel = UILabel()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()

    private enum DragHandleChoice {
        case start
        case end
    }

    var duration: Float64 = 15
    var videoDuration: CGFloat = 0
    var startIndicator = VideoStartIndicator()
    var endIndicator = VideoEndIndicator()
    var progressIndicator = VideoProgressIndicator()
    var topLoopView = UIView()
    var bottomLoopView = UIView()
    var playButton = UIButton(type: .system)
    
    var progressPercentage: CGFloat = 0 // Represented in percentage
    var startPercentage: CGFloat = 0 // Represented in percentage
    var endPercentage: CGFloat = 100 // Represented in percentage

     var minSpace: Float = 1 // In Seconds
     var maxSpace: Float = 0 // In Seconds

     var isProgressIndicatorSticky: Bool = false
     var isProgressIndicatorDraggable: Bool = true
    var isUpdatingThumbnails = false
    var isReceivingGesture: Bool = false

    var startIndicatorLeft: Constraint?
    var endIndicatorLeft: Constraint?
    var progressIndicatorLeft: Constraint?
    var videoCachingManeger = VideoCachingManeger()
    
    override  init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        insertUI()
        basicSetUI()
        anchorUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getVideoSequenceOfTime() {
        guard let asset = asset else { return }
        videoCachingManeger.generateVideoSequenceOfTime(from: asset) { [weak self] items in
            self?._displayVideoframeImages = items
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
     func showVideoCutState(_ cutState: Bool = false) {
        endIndicator.backgroundColor = cutState ? .systemYellow : .black
        startIndicator.backgroundColor = cutState ? .systemYellow : .black
        topLoopView.backgroundColor = cutState ? .systemYellow : .black
        bottomLoopView.backgroundColor = cutState ? .systemYellow : .black
    }
}

extension VideoNavigationView {
    // MARK: - Crop Handle Drag Functions

    @objc  func startDragged(recognizer: UIPanGestureRecognizer) {
           let fullWidth = collectionView.frame.width
           updateGestureStatus(recognizer: recognizer)
           let translation = recognizer.translation(in: self)
           //  let position = value * frame.width / 100
           var position: CGFloat = (startPercentage * (fullWidth - fullWidth / 15)) / 100
           position = position + translation.x

           if position < 0 { position = 0 }

           if position > fullWidth - fullWidth / 15 {
               position = fullWidth - fullWidth / 15
           }

           print(endPercentage / 100 * fullWidth, endPercentage / 100 * (fullWidth - fullWidth / 15))

           if position > endPercentage / 100 * (fullWidth - fullWidth / 15) {
               position = endPercentage / 100 * (fullWidth - fullWidth / 15)
           }

           recognizer.setTranslation(.zero, in: self)

           setCenterCutLabel()
        if position == 0 {
            if recognizer.state == .ended {
                showVideoCutState(false)
            }
            startIndicatorLeft?.update(offset: 1)
        } else {
            if recognizer.state == .ended {
                showVideoCutState(true)
            }
            startIndicatorLeft?.update(offset: position)
        }
           startIndicatorLeft?.update(offset: position)
           startPercentage = position * 100 / (fullWidth - fullWidth / 15)

           let startSeconds = duration * Float64(position / fullWidth)
           let endSeconds = duration * (endPercentage / 100 * (fullWidth - fullWidth / 15) / fullWidth) + 1
           setMaxCutLabelTime(startSeconds: startSeconds, endSeconds: endSeconds)
           delegate?.didChangeTimeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
           if position != 0 {
               progressIndicatorLeft?.update(offset: 0)
           }
           let progressSeconds = duration * Float64(position / fullWidth)
           
         //  delegate?.indicatorDidChangePosition(videoNavigationView: self, position: progressSeconds)
           
           progressPercentage = position * 100 / fullWidth
           layoutSubviews()
       }

       @objc  func endDragged(recognizer: UIPanGestureRecognizer) {
           let fullWidth = collectionView.frame.width
           updateGestureStatus(recognizer: recognizer)
           let translation = recognizer.translation(in: self)
           var position: CGFloat = (endPercentage * (fullWidth - fullWidth / 15)) / 100
           position = position + translation.x

           if position < 0 { position = 0 }

           if position > fullWidth - (fullWidth / 15) {
               position = fullWidth - (fullWidth / 15)
           }

           if position < startPercentage / 100 * (fullWidth - fullWidth / 15) {
               position = startPercentage / 100 * (fullWidth - fullWidth / 15)
           }

           let leftPosition = -(fullWidth - fullWidth / 15 - position)
           setCenterCutLabel()
           recognizer.setTranslation(.zero, in: self)
           let startSeconds: Float64 = secondsFromValue(value: startPercentage)
           let endSeconds: Float64 = duration * Float64(position / fullWidth) + 1
           if startSeconds + endSeconds == 15 {
               if recognizer.state == .ended {
                   showVideoCutState(false)
               }
           }
           delegate?.didChangeTimeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
           setMaxCutLabelTime(startSeconds: startSeconds, endSeconds: endSeconds)
           endIndicatorLeft?.update(offset: leftPosition)
           progressIndicatorLeft?.update(offset: 0)

           let progressSeconds = duration * Float64(position / fullWidth)
        //   delegate?.indicatorDidChangePosition(videoNavigationView: self, position: progressSeconds)
           print("""
                   startPercentage = \(startPercentage)
                   startSeconds    = \(startSeconds)
                   endSeconds      = \(endSeconds)
                   progressSeconds = \(progressSeconds)
               """)
           endPercentage = position * 100 / (fullWidth - fullWidth / 15)
           layoutSubviews()
       }

    @objc func progressDragged(recognizer: UIPanGestureRecognizer) {
        if !isProgressIndicatorDraggable {
            return
        }
        let fullWidth = collectionView.frame.width
        updateGestureStatus(recognizer: recognizer)

        let translation = recognizer.translation(in: self)

        let positionLimitStart = startPercentage * (fullWidth - fullWidth / 15) / 100
        let positionLimitEnd = endPercentage * (fullWidth - fullWidth / 15) / 100

        var position = progressPercentage * (fullWidth - fullWidth / 15) / 100

        position = position + translation.x

        if position < positionLimitStart {
            position = positionLimitStart
        }

        if position > positionLimitEnd {
            position = positionLimitEnd
        }

        recognizer.setTranslation(.zero, in: self)

        if positionLimitStart > 0 {
            progressIndicatorLeft?.update(offset: position - positionLimitStart)
        } else {
            progressIndicatorLeft?.update(offset: position)
        }

        let percentage = position * 100 / (fullWidth - fullWidth / 15)

        let progressSeconds = duration * Float64(position / fullWidth)

//        print("""
//          position           = \(position)
//          positionLimitStart = \(positionLimitStart)
//          percentage1        = \(percentage)
//          percentage2        = \(position * 100 / fullWidth)
//          progressSeconds    = \(progressSeconds)
//          recognizer end     = \(recognizer.state == .ended)
//          recognizer end     = \(recognizer.state == .changed)
//        """)
//        
        delegate?.indicatorDidChangePosition(videoNavigationView: self, position: progressSeconds, state: recognizer.state == .ended)
        progressPercentage = percentage

        layoutSubviews()
    }
    
    @objc func playTappedTapped(_ sender: UIButton) {
        delegate?.didSelectedPlayTapped(sender)
    }
}

extension VideoNavigationView {
    private func updateGestureStatus(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            isReceivingGesture = true
        } else if recognizer.state == .ended {
            isReceivingGesture = false
        }
    }

    private func secondsFromValue(value: CGFloat) -> Float64 {
        return duration * Float64(value / 100)
    }

    func setCenterCutLabel() {
        var startX = startIndicator.frame.origin.x
        let endX = endIndicator.frame.origin.x + 20
        if startX < 0 {
            startX = 0
        }
        maxCutTimeLabel.center.x = (startX + endX) / 2
    }

    func setMaxCutLabelTime(startSeconds: Float64, endSeconds: Float64) {
        let maxCutTime = (endSeconds - startSeconds)
        delegate?.didChangeCutMaxTime(cutTime: maxCutTime)
        maxCutTimeLabel.text = "\((trunc(10.0 * maxCutTime)) / 10)"
    }
}

extension VideoNavigationView: UICollectionViewDelegate, UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _displayVideoframeImages.count
        // return _displayKeyframeImages.count
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: VideoNavigationCollectionCell = collectionView.dequeueCell(indexPath: indexPath)
        cell.configureCell(asset: asset, videoFrame: _displayVideoframeImages[indexPath.row])
        return cell
    }
}

extension VideoNavigationView: UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = (screenWidth - 72) / 5.5
        if asset?.duration.seconds ?? 15 < 15 {
            width = (screenWidth - 72) / 5
        }
        return CGSize(width: width, height: 40)
    }
}

extension VideoNavigationView: UIScrollViewDelegate {
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // _asset is nil or videoPlayer not readyForDisplay
        progressIndicatorLeft?.update(offset: 0)
        delegate?.videoScrollViewDidScroll(scrollView: scrollView)
    }

     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.videoScrollViewDidEndDragging(scrollView: scrollView)
    }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.videoScrollViewDidEndDecelerating(scrollView: scrollView)
    }
}

/*
 private func processHandleDrag(
     recognizer: UIPanGestureRecognizer,
     drag: DragHandleChoice,
     currentPositionPercentage: CGFloat,
     currentIndicator: UIView
 ) {
     updateGestureStatus(recognizer: recognizer)

     let translation = recognizer.translation(in: self)

     var position: CGFloat = positionFromValue(value: currentPositionPercentage) // self.startPercentage or self.endPercentage
     position = position + translation.x

     if drag == .start {
         if position < 10 { position = 10 }
     } else {
         if position < 35 { position = 35 }
     }

     if position > collectionView.frame.width + 7.5 {
         if drag == .start {
             position = collectionView.frame.width + 7.5
         } else {
             if position > collectionView.frame.width + 30 {
                 position = collectionView.frame.width + 30
             }
         }
     }

     let positionLimits = getPositionLimits(with: drag)
     position = checkEdgeCasesForPosition(with: position, and: positionLimits.min, and: drag)

     if Float(duration) > maxSpace && maxSpace > 0 {
         if drag == .start {
             if position < positionLimits.max {
                 position = positionLimits.max
             }
         } else {
             if position > positionLimits.max {
                 position = positionLimits.max
             }
         }
     }

     recognizer.setTranslation(.zero, in: self)

     currentIndicator.center = CGPoint(x: position, y: currentIndicator.center.y)
     let percentage = currentIndicator.center.x * 100 / frame.width
     //  print("percentage = ",percentage, currentIndicator.center.x * 100)
     // let percentage = (currentIndicator.center.x - 10) * 100 / collectionView.frame.width

     let startSeconds = secondsFromValue(value: startPercentage)
     let endSeconds = secondsFromValue(value: endPercentage)

     // self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)

     var progressPosition: CGFloat = 0.0

     if drag == .start {
         startPercentage = percentage
     } else {
         endPercentage = percentage
     }

     if drag == .start {
         progressPosition = positionFromValue(value: startPercentage)

         progressPosition += 12.5
     } else {
         if recognizer.state != .ended {
             progressPosition = positionFromValue(value: endPercentage)
             print(progressPosition, "progressPosition end")
             progressPosition -= 22.5
         } else {
             progressPosition = positionFromValue(value: startPercentage)
             progressPosition += 22.5
         }
     }

     progressIndicator.center = CGPoint(x: progressPosition, y: progressIndicator.center.y)

     let progressPercentage = (progressIndicator.center.x * 100) / collectionView.frame.width
     if self.progressPercentage != progressPercentage {
         let progressSeconds = secondsFromValue(value: progressPercentage)
         // print("\nprogressSeconds =", progressSeconds)
         //  self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
     }

     //    self.progressPercentage = progressPercentage

     layoutSubviews()
 }

 private func getPositionLimits(with drag: DragHandleChoice) -> (min: CGFloat, max: CGFloat) {
     if drag == .start {
         return (
             positionFromValue(value: endPercentage - valueFromSeconds(seconds: minSpace)),
             positionFromValue(value: endPercentage - valueFromSeconds(seconds: maxSpace))
         )
     } else {
         return (
             positionFromValue(value: startPercentage + valueFromSeconds(seconds: minSpace)),
             positionFromValue(value: startPercentage + valueFromSeconds(seconds: maxSpace))
         )
     }
 }

 private func valueFromSeconds(seconds: Float) -> CGFloat {
     return CGFloat(seconds * 100) / CGFloat(duration)
 }

 // MARK: - Drag Functions Helpers

 private func positionFromValue(value: CGFloat) -> CGFloat {
     let position = value * frame.width / 100
     //  let position = value * collectionView.frame.width / 100
     return position
 }

 private func checkEdgeCasesForPosition(with position: CGFloat, and positionLimit: CGFloat, and drag: DragHandleChoice) -> CGFloat {
     if drag == .start {
         if Float(duration) < minSpace {
             return 0
         } else {
             if position > positionLimit {
                 return positionLimit
             }
         }
     } else {
         if Float(duration) < minSpace {
             return frame.size.width
             //  return collectionView.frame.width
         } else {
             print(position, positionLimit, "checkEdgeCasesForPosition")
             if position < positionLimit {
                 return positionLimit
             }
         }
     }

     return position
 }
 */
