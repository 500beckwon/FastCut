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

    var rightButton = UIButton(type: .system)
    var playerLayer = AVPlayerLayer()
    var playerView = UIView()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: screenWidth/4-1, height: screenWidth/4-1)
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
    
    private var listButton: UIButton?
    private var videoItem: AVPlayerItem?
    private var player: AVPlayer?
    private var headerRise = false
    
    private let viewModel = VideoListViewModel()
    private let requestList = BehaviorRelay<Void>(value: Void())
    private let selectedAsset = PublishRelay<PHAsset>()
    private let videoList = BehaviorRelay<[VideoItem]>(value: [])
    private let disposeBag = DisposeBag()
    
    var listTopConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insertUI()
        basicSetUI()
        anchorUI()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        
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
    
    private func bindUI() {
        let transform = viewModel.transform(input: makeInput())
        transform
            .fetchVideo
            .withUnretained(self)
            .do(onNext: {
                guard let firstAsset = $0.1.first?.asset else { return }
                $0.0.selectedAsset.accept(firstAsset)
            })
            .map { $0.1}
            .bind(to: collectionView
                .rx
                .items(cellIdentifier: VideoCollectionViewCell.reuseIdentifier,
                       cellType: VideoCollectionViewCell.self)) { index, item , cell in
                cell.requestVideoThumbnail(asset: item.asset)
            }.disposed(by: disposeBag)
        
        transform
            .confirmSelectedAsset
            .observe(on: MainScheduler.instance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                self.playerLayerBasicSet(item)
            }).disposed(by: disposeBag)
        
        transform
            .editTapped
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            }).disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(VideoItem.self)
            .map { $0.asset }
            .bind(to: selectedAsset)
            .disposed(by: disposeBag)
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
}
