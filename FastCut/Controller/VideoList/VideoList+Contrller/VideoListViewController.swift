//
//  VideoListViewController.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit
import AVFoundation
import Photos
import SnapKit
import RxSwift
import RxCocoa

final class VideoListViewController: UIViewController {
    
    var backButton = UIButton(type: .system)
    var rightButton = UIButton(type: .system)
    var playerLayer = AVPlayerLayer()
    var playerView = UIView()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
    
    private var listButton: UIButton?
    private var videoItem: AVPlayerItem?
    private var player: AVPlayer?
    private var headerRise = false
    
    private let viewModel = VideoListViewModel()
    private let requestList = PublishRelay<Void>()
    private let selectedAsset = PublishRelay<PHAsset>()
    private let videoList = BehaviorRelay<[VideoItem]>(value: [])
    private let disposeBag = DisposeBag()
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        insertUI()
        basicSetUI()
        anchorUI()
        bind()
        bindUI()
        requestList.accept(Void())
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if headerRise == true {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        player?.play()
    }
    
    private func makeInput() -> VideoListViewModel.Input {
        let requestList = requestList.do()
        let selectedAsset = selectedAsset.do(onNext: { [weak self] in
            self?.viewModel.selectedAsset = $0
            self?.player?.pause()
        })
        
        let tapped = rightButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance)
        return VideoListViewModel.Input(fetchVideo: requestList, selectAsset: selectedAsset, editTapped: tapped)
    }
    
    private func bind() {
        let transform = viewModel.transform(input: makeInput())
        transform
            .fetchVideo
            .bind(to: videoList)
            .disposed(by: disposeBag)
        
        transform
            .confirmSelectedAsset
            .observeOn(MainScheduler.instance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                self.playerLayerBasicSet(item)
            }).disposed(by: disposeBag)
        
        transform
            .editTapped
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            }).disposed(by: disposeBag)
    }
    
    private func bindUI() {
        videoList
            .filter { !$0.isEmpty }
            .do(onNext: { [weak self] assetList in
                guard let firstAsset = assetList.first?.asset else { return }
                self?.selectedAsset.accept(firstAsset)
            }).asDriver(onErrorJustReturn: [])
            .drive { [weak self] _ in
                self?.collectionView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    func playerLayerBasicSet(_ assetItem: AVPlayerItem) {
        if player?.currentItem == nil {
            player = AVPlayer(playerItem: assetItem)
            player?.isMuted = false
            playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.frame = self.playerView.bounds
            playerView.layer.addSublayer(self.playerLayer)
        } else {
            self.player?.replaceCurrentItem(with: assetItem)
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
        player?.play()
        setMute()
    }
    
    func setMute() {
        player?.isMuted = true
    }
    
    @objc func backButtonTapped() {
     
        
        player?.pause()
        player?.replaceCurrentItem(with: nil)
     
    }
}

extension VideoListViewController: VideoListCollectionHeaderViewDelegate {
    func didSelectedListupButton(button: UIButton) {
        headerRise = button.isSelected
        switch button.isSelected {
        case true  : upCollectionView()
        case false : downCollectionView()
        }
    }
    
    func didSelectedCameraButton() {
     
    }
}

extension VideoListViewController {
    func upCollectionView() {
        UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
            guard let self = self else { return }
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.collectionView.frame.origin.y = -(self.view.safeAreaInsets.top)
            self.collectionView.frame.size = CGSize(width: self.screenWidth, height: self.screenHeight)
            self.collectionView.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.setNavigationBarHidden(self.headerRise, animated: true)
        }
    }
    
    func downCollectionView() {
        UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
            guard let self = self else { return }
//            let playerHeight = screenHeight/2 + 57
//            self.collectionView.frame.origin.y = (screenHeight/2 + 57)
//            self.collectionView.frame.size = CGSize(width: screenWidth, height: screenHeight -  playerHeight)
            self.collectionView.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.setNavigationBarHidden(self.headerRise, animated: true)
        }
    }
}

extension VideoListViewController: UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: VideoListCollectionHeaderView = collectionView.dequeueSupplementaryCell(indexPath: indexPath)
        listButton = header.listupButton
        header.delegate = self
        return header
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = videoList.value[indexPath.item].asset
        if headerRise {
            headerRise = false
            listButton?.isSelected = headerRise
            downCollectionView()
        }
        selectedAsset.accept(media)
    }
}

extension VideoListViewController: UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.value.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: VideoCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath)
        cell.requestVideoThumbnail(asset:  videoList.value[indexPath.item].asset)
        return cell
    }
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 57)
    }
}
