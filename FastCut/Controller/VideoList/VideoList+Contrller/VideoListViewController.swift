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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: screenWidth/3-1, height: screenHeight/3-1)
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
        
    private let viewModel = VideoListViewModel()
    private let requestList = Driver.just(Void())
 //   private let selectedAsset = PublishRelay<VideoItem>()
   // private let videoList = BehaviorRelay<[VideoItem]>(value: [])
    private let disposeBag = DisposeBag()
    
    var listTopConstraint: Constraint?
    
    let playerManager = VideoPlayerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.authorized.subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
        insertUI()
        basicSetUI()
        anchorUI()
        bindUI()
//        rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
//            .map { _ in Void() }
//            .asDriver { _ in Driver.empty() }
//            .drive (onNext:{
//              print($0,"asdfsdafa")
//            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func makeInput() -> VideoListViewModel.Input {
        let requestList = requestList
        let selectedAsset = collectionView.rx.modelSelected(VideoItem.self).asDriver()
        let tapped = rightButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).asDriver(onErrorJustReturn: Void())
        return VideoListViewModel.Input(fetchVideo: requestList, selectAsset: selectedAsset, editTapped: tapped)
    }
    
    private func bindUI() {
        let transform = viewModel.transform(input: makeInput())
        transform
            .fetchVideo
            .drive(collectionView
                .rx
                .items(cellIdentifier: VideoCollectionViewCell.reuseIdentifier,
                       cellType: VideoCollectionViewCell.self)) { index, item , cell in
                cell.requestVideoThumbnail(asset: item.asset)
            }.disposed(by: disposeBag)
        
        transform
            .confirmSelectedAsset
            .throttle(.milliseconds(250))
            .drive(onNext: { [weak self] item in
                guard let self = self else { return }
              
            }).disposed(by: disposeBag)
        
        transform
            .editTapped
            .drive(onNext: { [weak self] _ in
                
            }).disposed(by: disposeBag)
    
    }
}
