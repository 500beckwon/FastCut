//
//  Extension+VideoPlayViewController.swift
//  picple
//
//  Created by GNComms on 2021/12/29.
//  Copyright © 2021 Choi. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVKit

extension VideoPlayViewController {
    func insertUI() {
        //view.addSubview(scrollView)
        view.addSubview(playerView)
        view.addSubview(playButton)
        view.addSubview(videoNavigationView)
        view.addSubview(endtimeLabel)
        view.addSubview(indicator)
    }

    func basicSetUI() {
        navigationBarBasicSet()
        muteButtonBasicSet()
        playerViewBasicSet()
        sendVideoDircetoryButtonBasicSet()
      //  playButtonBasicSet()
        backButtonBasicSet()
      //  viewControllerBasicSet()
        endTimeLabelBasicSet()
        videoNavigationViewBasicSet()
        timeLabelBasicSet()
        indicatorBasicSet()
    }

    func anchorUI() {
        //scrollViewAnchor()
        playerViewAnchor()
      //  playButtonAnchor()
        videoNavigationViewAnchor()
        endTimeLabelAnchor()
        indicatorAnchor()
    }
    
    func navigationBarBasicSet() {
        view.backgroundColor = .white
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = false
       
        //bottomLineHidden()
    }

    func playerViewBasicSet() {
        playerView.backgroundColor = .white
        playerView.clipsToBounds = true
        playerView.layer.cornerRadius = 20
    }

    func playButtonBasicSet() {
        playButton.setTitle("Play", for: .normal)
        playButton.setTitle("Stop", for: .selected)
        playButton.setTitleColor(.orange, for: .normal)
        playButton.setTitleColor(.orange, for: .selected)
        playButton.titleLabel?.font =  .boldSystemFont(ofSize: 20)
        playButton.backgroundColor = .clear
        playButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        playButton.tintColor = .clear
    }
    
    func muteButtonBasicSet() {
        muteButton.setImage(UIImage(named: "muteButton"), for: .selected)
        muteButton.setImage(UIImage(named: "muteOffButton"), for: .normal)
        muteButton.tintColor = .clear
        muteButton.backgroundColor = .clear
        navigationItem.titleView = muteButton
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
    }
    
    func backButtonBasicSet() {
       // backButton.apply([.renewalBackButton])
        backButton.setImage(UIImage(named: "WhiteDismiss"), for: .normal)
        backButton.backgroundColor = .clear
        let barButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButton
    }

    func sendVideoDircetoryButtonBasicSet() {
        sendVideoDircetoryButton.setTitle("다음", for: .normal)
        sendVideoDircetoryButton.setTitleColor(.systemBlue, for: .normal)
        sendVideoDircetoryButton.backgroundColor = .clear
        sendVideoDircetoryButton.titleLabel?.font =  .boldSystemFont(ofSize: 16)
        sendVideoDircetoryButton.addTarget(self, action: #selector(cutAndPlayVideo), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: sendVideoDircetoryButton)
        navigationItem.rightBarButtonItem = barButton
    }

    func endTimeLabelBasicSet() {
        endtimeLabel.textColor = .white
        endtimeLabel.backgroundColor = .black
        endtimeLabel.font = .boldSystemFont(ofSize: 12)
        endtimeLabel.textAlignment = .center
        endtimeLabel.layer.cornerRadius = 5
        endtimeLabel.clipsToBounds = true
    }
    
    func videoNavigationViewBasicSet() {
        videoNavigationView.delegate = self
       // videoNavigationView.layer.borderWidth = 1
       // videoNavigationView.layer.borderColor = UIColor.orange.cgColor
        videoNavigationView.layer.cornerRadius = 5
        videoNavigationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        videoNavigationView.clipsToBounds = true
    }

    func viewControllerBasicSet() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        view.addGestureRecognizer(tapGesture)
    }
    
    func timeLabelBasicSet() {
        timeCutLabel.font =  .boldSystemFont(ofSize: 12)
        timeCutLabel.textColor = .black
        timeCutLabel.backgroundColor = .white
        timeCutLabel.textAlignment = .center
        timeCutLabel.text = "15.0초"
        timeCutLabel.layer.cornerRadius = 5
        timeCutLabel.clipsToBounds = true
    }
    
    func indicatorBasicSet() {
        indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        indicator.backgroundColor = UIColor(displayP3Red: 120 / 255, green: 120 / 255, blue: 120 / 255, alpha: 0.5)
        indicator.color = .white
        indicator.layer.cornerRadius = 20
        indicator.clipsToBounds = true
    }
    
    func scrollViewAnchor() {
        scrollView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view).offset(-90)
        }
    }

    func playerViewAnchor() {
       // playerView.frame = view.frame
//        playerView.snp.makeConstraints { make in
//            make.top.equalTo(scrollView)
//            make.left.right.equalTo(scrollView)
//            width = make.width.equalTo(screenWidth).constraint
//            height = make.height.equalTo(screenWidth).constraint
//            make.bottom.equalTo(scrollView)
//        }
        playerView.snp.makeConstraints { make in
            let naviHeight = navigationController?.navigationBar.frame.height ?? 40
            make.left.right.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-naviHeight)
            make.bottom.equalTo(view).offset(-90)
            //playerViewHeight = make.height.equalTo(screenHeight).constraint
        }
    }

    func playButtonAnchor() {
        playButton.snp.makeConstraints { make in
            make.center.equalTo(playerView)
            make.height.equalTo(25)
            make.width.equalTo(50)
        }
    }
    
    func videoNavigationViewAnchor() {
        videoNavigationView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(50)
            make.top.equalTo(playerView.snp.bottom).offset(16)
            //make.bottom.equalTo(view).offset(-40)
        }
    }
    
    func endTimeLabelAnchor() {
        endtimeLabel.snp.makeConstraints { make in
            //make.centerX.equalTo(view)
            make.centerX.equalTo(videoNavigationView.progressIndicator.snp.centerX)
            //make.bottom.equalTo(view).offset(-100)
            make.bottom.equalTo(videoNavigationView.snp.top).offset(-40)
            make.height.equalTo(25)
            make.width.equalTo(60)
        }
    }
    
    func indicatorAnchor() {
        indicator.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.width.equalTo(40)
            make.centerY.equalTo(view).offset(-40)
        }
    }
}

/*
 func sliderMoveValue(_ value: CGFloat) {
 guard let duration = self.player?.currentItem?.duration else { return }
 let value = Float64(value) * CMTimeGetSeconds(duration)
 let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
 self.player?.seek(to: seekTime)
 }
 
 /// n초후로 이동
 /// - Parameter sender: forwardButton
 @objc func jumpForwardAction(_ sender: UIButton) {
     guard let currentTime = player?.currentTime() else { return }
     let currentTimeInSecondsPlus10 = CMTimeGetSeconds(currentTime).advanced(by: 5)
     let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus10), timescale: 1)
     player?.seek(to: seekTime)
 }

 /// n초전으로 이동
 /// - Parameter sender: backwardButton
 @objc func backForwardAction(_ sender: UIButton) {
     guard let currentTime = player?.currentTime() else { return }
     let currentTimeInSecondsMinus10 = CMTimeGetSeconds(currentTime).advanced(by: -5)
     let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus10), timescale: 1)
     player?.seek(to: seekTime)
 }
 */
