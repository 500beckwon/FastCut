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
    private var assetImageView = UIImageView()
    private var timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        insertUI()
        basicSetUI()
        anchorUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetImageView.image = nil
        timeLabel.text = nil
    }
}

extension VideoCollectionViewCell {
    func requestVideoThumbnail(asset: PHAsset?) {
        guard let asset = asset else { return }
        let size = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        let phVideoOption = PHVideoRequestOptions()
        phVideoOption.isNetworkAccessAllowed = true
        phVideoOption.deliveryMode = .fastFormat
        phVideoOption.version = .current

        let imageRequestOption = PHImageRequestOptions()
        imageRequestOption.deliveryMode = .fastFormat
        imageRequestOption.isNetworkAccessAllowed = true

        PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill , options: imageRequestOption) { image, hash in
            DispatchQueue.main.async { [weak self] in
                self?.assetImageView.image = image
            }
        }

        PHImageManager.default().requestAVAsset(forVideo: asset, options: phVideoOption) { asset, mix, hash in
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

private extension VideoCollectionViewCell {
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
        assetImageView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
    }

    func timeLabelAnchor() {
        timeLabel.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom).offset(-8)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-8)
            $0.height.equalTo(20)
        }
    }

    func timeLabelBasicSet() {
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = .clear
        timeLabel.font = .boldSystemFont(ofSize: 12)
        timeLabel.layer.cornerRadius = 5
        timeLabel.clipsToBounds = true
    }

    func assetImageViewBasicSet() {
        assetImageView.contentMode = .scaleAspectFill
        assetImageView.backgroundColor = .clear
        assetImageView.clipsToBounds = true
    }
}
