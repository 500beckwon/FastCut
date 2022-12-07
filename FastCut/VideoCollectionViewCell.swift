//
//  VideoCollectionViewCell.swift
//  picple
//
//  Created by ByungHoon Ann on 2022/09/13.
//  Copyright © 2022 Choi. All rights reserved.
//

import UIKit
import Photos

final class VideoCollectionViewCell: UICollectionViewCell {
    var assetImageView = UIImageView()
    var timeLabel = UILabel()
    fileprivate let imageManager = PHImageManager()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        insertUI()
        basicSetUI()
        anchorUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func insertUI() {
        contentView.addSubview(assetImageView)
        contentView.addSubview(timeLabel)
    }

    func basicSetUI() {
        assetImageViewBasicSet()
        timeLabelBasicSet()
    }

    func anchorUI() {
        assetImageViewAnchor()
        timeLabelAnchor()
    }

    func assetImageViewAnchor() {
        assetImageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self)
        }
    }

    func timeLabelAnchor() {
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.bottom).offset(-8)
            make.right.equalTo(contentView.snp.right).offset(-8)
            // make.width.equalTo(100)
            make.height.equalTo(20)
        }
    }

    func timeLabelBasicSet() {
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = .black
        timeLabel.font = .boldSystemFont(ofSize: 12)
        timeLabel.layer.cornerRadius = 5
        timeLabel.clipsToBounds = true
    }

    func assetImageViewBasicSet() {
        assetImageView.contentMode = .scaleAspectFill
        assetImageView.backgroundColor = .clear
        assetImageView.clipsToBounds = true
    }

    func requestVideoThumbnail(asset: PHAsset?) {
        guard let asset = asset else { return }
        let size = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        let phVideoOption = PHVideoRequestOptions()
        phVideoOption.isNetworkAccessAllowed = true
        phVideoOption.deliveryMode = .mediumQualityFormat
        phVideoOption.version = .current
        phVideoOption.progressHandler = { progress, error, stop, info in
           // print(progress, error, stop, info, "오홓헿헿")
        }
//        PHImageManager.default().requestAVAsset(forVideo: asset, options: phVideoOption) { avAsset, mix, info in
//            print("헤쉬헤", asset, mix, info)
//
//            guard let avAsset = avAsset else {
//                print("Asset is nil. Info: \(String(describing: info))")
//                return
//              }
//              guard let videoTrack = avAsset.tracks(withMediaType: .video).first else {
//                print("Cound not extract video track from AvAsset") // <- My issue
//                return
//              }
//
//            print(videoTrack, "뷔디오트랙")
//        }

        let imageRequestOption = PHImageRequestOptions()
       // imageRequestOption.isSynchronous = true
        imageRequestOption.deliveryMode = .fastFormat
        imageRequestOption.isNetworkAccessAllowed = true
        imageRequestOption.progressHandler = { progress, error, stop, info in
      //      print(progress, error, stop, info, "프로그레스")
        }

        PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: imageRequestOption) { image, hash in
         //   print("썸네일 리퀘스트", image, hash)
            DispatchQueue.main.async { [weak self] in
                self?.assetImageView.image = image
            }
        }

        PHImageManager.default().requestAVAsset(forVideo: asset, options: phVideoOption) { asset, mix, hash in
      //      print(asset?.duration.seconds, "시각")
            guard let item = asset else { return }
            let second = trunc(item.duration.seconds * 10)/10
            let customDuration = CMTime(seconds: second, preferredTimescale: 600)
            let totalTimeInSeconds = CMTimeGetSeconds(customDuration)
            let remainingTimeInSeconds = totalTimeInSeconds

            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.timeLabel.text = "\(minsStr):\(secsStr)"
            }
        }
    }
}
