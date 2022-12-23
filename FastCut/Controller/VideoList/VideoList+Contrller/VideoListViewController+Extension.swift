//
//  VideoListViewController+Extension.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit

extension VideoListViewController {
    func insertUI() {
        [playerView, collectionView].forEach {
            view.addSubview($0)
        }
    }
    
    func basicSetUI() {
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
        playerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(screenWidth)
        }
    }
    
    func collectionViewAnchor() {
        collectionView.snp.makeConstraints {
            listTopConstraint = $0.top.equalTo(playerView.snp.bottom).constraint
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func playerViewBasicSet() {
        playerView.backgroundColor = .black
        playerView.clipsToBounds = true
        playerView.layer.cornerRadius = 20
        playerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func videoEditButtonBasicSet() {
        rightButton.setTitle("다음", for: .normal)
        rightButton.backgroundColor = .clear
        rightButton.setTitleColor(.systemBlue, for: .normal)
        let barButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func collectionViewBasicSet() {
        collectionView.backgroundColor = .white
        collectionView.registerCell(VideoCollectionViewCell.self)
    }
    
    func navigationBarBasicSet() {
        view.backgroundColor = .systemBackground
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = false
    }
}
