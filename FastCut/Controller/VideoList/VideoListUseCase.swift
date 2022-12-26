//
//  VideoListUseCase.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/26.
//

import Photos
import RxCocoa

protocol VideoListUseCase: AnyObject {
    func requestVideoAssetList(with assetManager: PHAssetManager) -> Driver<[VideoItem]>
    func requestVideoPlayerItem(assetManager: PHAssetManager, for asset: PHAsset) -> Driver<AVPlayerItem>
}

final class VideoListUseCaseImpl: VideoListUseCase {
    func requestVideoAssetList(with assetManager: PHAssetManager) -> Driver<[VideoItem]> {
        return PHPhotoLibrary
            .authorized
            .asDriver(onErrorJustReturn: false)
            .flatMap { accept -> Driver<[VideoItem]> in
            return accept ?
                Driver.just(assetManager.getPHAssets(with: .video)
                .map { VideoItem(asset: $0)}) : Driver.just([])
        }
    }
    
    func requestVideoPlayerItem(assetManager: PHAssetManager, for asset: PHAsset) -> Driver<AVPlayerItem> {
        return assetManager.requestAVPlayerItem(for: asset)
    }
}
