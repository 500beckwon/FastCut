//
//  VideoListViewModel.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import Photos
import RxSwift
import RxCocoa

final class VideoListViewModel {
    struct Input {
        let fetchVideo: Driver<Void>
        let selectAsset: Driver<VideoItem>
        let editTapped: Driver<Void>
    }
    
    struct Output {
        let fetchVideo: Driver<[VideoItem]>
        let confirmSelectedAsset: Driver<AVPlayerItem>
        let editTapped: Driver<VideoItem>
    }
    
    let useCase: VideoListUseCase
    let assetManager: PHAssetManager
     
    init(assetManager: PHAssetManager = PHAssetManager.shared,
         useCase: VideoListUseCase = VideoListUseCaseImpl()) {
        self.useCase = useCase
        self.assetManager = assetManager
    }
    
    func transform(input: Input) -> Output {
        let requestList = input.fetchVideo.flatMap { [weak self] _ -> Driver<[VideoItem]> in
            guard let self = self else { return .never() }
            return self.useCase.requestVideoAssetList(with: self.assetManager)
        }
        
        let selectedAsset = input.selectAsset.flatMap { [weak self] item -> Driver<AVPlayerItem> in
            guard let self = self else { return .never() }
            return self.useCase.requestVideoPlayerItem(assetManager: self.assetManager, for: item.asset)
        }
        
        let editTapped = input.selectAsset
        
        return Output(fetchVideo: requestList,
                      confirmSelectedAsset: selectedAsset,
                      editTapped: editTapped)
    }
}


