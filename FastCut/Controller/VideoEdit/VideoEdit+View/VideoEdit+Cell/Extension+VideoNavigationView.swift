//
//  Extension+VideoNavigationView.swift
//  VideoEdit
//
//  Created by GNComms on 2022/01/09.
//

import Foundation
import UIKit
import SnapKit

extension VideoNavigationView {
    func insertUI() {
        addSubview(playButton)
        addSubview(collectionView)
        addSubview(startIndicator)
        addSubview(endIndicator)
        
        addSubview(topLoopView)
        addSubview(bottomLoopView)
        
        addSubview(progressIndicator)
        addSubview(maxCutTimeLabel)
    }
    
    func basicSetUI() {
        playButtonBasicSet()
        collectionViewBasicSet()
        startIndicatorBasicSet()
        endIndicatorBasicSet()
        progressIndicatorBasicSet()
        maxCutTimeLabelBasicSet()
    }
    
    func anchorUI() {
        playButtonAnchor()
        collectionViewAnchor()
        startIndicatorAnchor()
        endIndicatorAnchor()
        
        loopViewAnchor()
        
        progressIndicatorAnchor()
        maxCutTimeLabelAnchor()
    }
    
    func playButtonBasicSet() {
        playButton.setImage(UIImage(named: "playButton"), for: .normal)
        playButton.setImage(UIImage(named: "pauseButton"), for: .selected)
        playButton.tintColor = .clear
        playButton.backgroundColor = .black
        playButton.layer.cornerRadius = 5
        playButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        playButton.addTarget(self, action: #selector(playTappedTapped(_:)), for: .touchUpInside)
    }
    
    func collectionViewBasicSet() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(VideoNavigationCollectionCell.self)
        collectionView.backgroundColor = .black
    }
    
    func endIndicatorBasicSet() {
        let endDrag = UIPanGestureRecognizer(target:self,
                                             action: #selector(endDragged(recognizer:)))


        endIndicator.isUserInteractionEnabled = true
      //  endIndicator.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        endIndicator.addGestureRecognizer(endDrag)
    }
    
    func startIndicatorBasicSet() {
        let startDrag = UIPanGestureRecognizer(target:self,
                                               action: #selector(startDragged(recognizer:)))

        startIndicator.isUserInteractionEnabled = true
        //startIndicator.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        startIndicator.addGestureRecognizer(startDrag)
    }
    
    func progressIndicatorBasicSet() {
        let progressDrag = UIPanGestureRecognizer(target:self,
                                                  action: #selector(progressDragged(recognizer:)))
        progressIndicator.addGestureRecognizer(progressDrag)
        progressIndicator.layer.cornerRadius = 2.5
        progressIndicator.clipsToBounds = true
    }
    
    func maxCutTimeLabelBasicSet() {
        maxCutTimeLabel.backgroundColor = .white
        maxCutTimeLabel.textColor = .black
        maxCutTimeLabel.layer.cornerRadius = 5
        maxCutTimeLabel.clipsToBounds = true
        maxCutTimeLabel.font = .boldSystemFont(ofSize: 12)
        maxCutTimeLabel.textAlignment = .center
    }
    
    func playButtonAnchor() {
        playButton.snp.makeConstraints { make in
            make.top.left.equalTo(self)
            make.width.equalTo(46)
            make.height.equalTo(50)
        }
    }
    
    func collectionViewAnchor() {
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(47)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(50)
        }
    }
    
    func startIndicatorAnchor() {
        startIndicator.snp.makeConstraints { make in
            startIndicatorLeft = make.left.equalTo(playButton.snp.right).offset(1).constraint
             make.width.equalTo(18)
            make.height.equalTo(50)
            make.centerY.equalTo(collectionView)
        }
    }
    
    func endIndicatorAnchor() {
        endIndicator.snp.makeConstraints { make in
            endIndicatorLeft = make.left.equalTo(collectionView.snp.right).constraint
            make.width.equalTo(18)
            make.height.equalTo(50)
            make.centerY.equalTo(collectionView)
        }
    }
    
    func loopViewAnchor() {
        topLoopView.backgroundColor = .black
        bottomLoopView.backgroundColor = .black
        topLoopView.snp.makeConstraints { make in
            make.left.equalTo(startIndicator.snp.right)
            make.right.equalTo(endIndicator.snp.left)
            make.height.equalTo(5)
            make.top.equalTo(collectionView.snp.top)
        }
        
        bottomLoopView.snp.makeConstraints { make in
            make.left.equalTo(startIndicator.snp.right)
            make.right.equalTo(endIndicator.snp.left)
            make.height.equalTo(5)
            make.bottom.equalTo(collectionView.snp.bottom)
        }
    }
    
    func progressIndicatorAnchor() {
        progressIndicator.snp.makeConstraints { make in
            make.width.equalTo(5)
            make.height.equalTo(45)
            make.centerY.equalTo(collectionView)
            progressIndicatorLeft = make.left.equalTo(startIndicator.snp.right).constraint
        }
    }
    
    func maxCutTimeLabelAnchor() {
        maxCutTimeLabel.center = center
        let width = screenWidth - 32
        //65 18 screew - 72
        maxCutTimeLabel.frame = CGRect(origin: CGPoint(x: width/2 + 20, y: 12.5), size: CGSize(width: 30, height: 25))
//        maxCutTimeLabel.snp.makeConstraints { make in
//            make.center.equalTo(self)
//            make.height.equalTo(25)
//            make.width.equalTo(50)
//        }
    }
}
