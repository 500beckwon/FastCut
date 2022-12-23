//
//  VideoNavigationCollectionCell.swift
//  picple
//
//  Created by GNComms on 2022/01/05.
//  Copyright © 2022 Choi. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoNavigationCollectionCell: UICollectionViewCell {
    private var imageView = UIImageView()
    var keyframeImage: KeyframeImage?
    var asset: AVAsset?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        insertUI()
        basicSetUI()
        anchorUI()
       // contentView.layer.borderWidth = 1
       // contentView.layer.borderColor = UIColor.white.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(asset: AVAsset?, videoFrame: VideoFrameImage) {
        guard let asset = asset else { return }
        imageView.image = VideoCachingManeger.getSingleVideoSequenceOfImage(from: asset, at: videoFrame.requestedTime)
    }

    private func insertUI() {
        contentView.addSubview(imageView)
    }

    private func basicSetUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
    }

    private func anchorUI() {
        imageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(contentView)
        }
    }
}
