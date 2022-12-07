//
//  VideoListViewController+Extension.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit

extension VideoListViewController {
    func insertUI() {
        view.addSubview(playerView)
        view.addSubview(collectionView)
    }
    
    func basicSetUI() {
        backButtonBasicSet()
        playerViewBasicSet()
        collectionViewBasicSet()
        navigationBarBasicSet()
        videoEditButtonBasicSet()
    }
    
    func anchorUI() {
        playerViewAnchor()
        collectionViewAnchor()
    }
}

private extension VideoListViewController {
    func playerViewAnchor() {
       // let topPadding = UIApplication.statusBarView?.frame.height ?? 20
      //  playerView.frame = CGRect(x: 0, y: topPadding, width: screenWidth, height: screenHeight/2 + 57 - topPadding)
    }
    
    func collectionViewAnchor() {
        let playerHeight = screenHeight/2 + 57
        collectionView.frame = CGRect(x: 0, y: screenHeight/2 + 57, width: screenWidth, height: screenHeight - playerHeight)
    }
    
    func playerViewBasicSet() {
        playerView.backgroundColor = .white
        playerView.clipsToBounds = true
        playerView.layer.cornerRadius = 20
        playerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func videoEditButtonBasicSet() {
        rightButton.setTitle("다음", for: .normal)
        rightButton.backgroundColor = .clear
        rightButton.setTitleColor(.systemBlue, for: .normal)
     //   rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func collectionViewBasicSet() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.registerHeaderCell(VideoListCollectionHeaderView.self)
        collectionView.registerCell(VideoCollectionViewCell.self)
    }
    
    func backButtonBasicSet() {
     //   backButton.apply([.renewalBackButton])
        backButton.setImage(UIImage(named: "WhiteDismiss"), for: .normal)
        let barButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButton
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    func navigationBarBasicSet() {
        //view.backgroundColor = .textBoldBlackColor
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .clear
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = false
        
    }
}
