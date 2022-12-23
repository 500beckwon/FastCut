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
        let fetchVideo: Observable<Void>
        let selectAsset: Observable<PHAsset>
        let editTapped: Observable<Void>
    }
    
    struct Output {
        let fetchVideo: Observable<[VideoItem]>
        let confirmSelectedAsset: Observable<AVPlayerItem>
        let editTapped: Observable<AVPlayerItem>
    }
    
    var selectedAsset: PHAsset?
    
    init() {
        
    }
    
    func transform(input: Input) -> Output {
        let requestList = input.fetchVideo.flatMap { [weak self] _ -> Observable<[VideoItem]> in
            guard let self = self else { return .never() }
            return self.list(option: .fetchOptions())
        }
        
        let selectedAsset = input.selectAsset.flatMap {
            return PHVideoPlayerOption.requestItem(asset: $0)
        }
        
        let editTapped = input.editTapped.flatMap { [weak self] _  -> Observable<AVPlayerItem> in
            guard let asset = self?.selectedAsset else { return .never() }
            return PHVideoPlayerOption.requestItem(asset: asset)
        }
        
        return Output(fetchVideo: requestList,
                      confirmSelectedAsset: selectedAsset,
                      editTapped: editTapped)
    }
    
    func list(option: PHFetchOptions) -> Observable<[VideoItem]> {
        return Observable.create { ob in
            if #available(iOS 14.0, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    
                    if status == .authorized {
                      //  let list =  PHAsset.fetchAssets(with: .video, options: option)
                        let list = PHAsset.fetchAssets(with: .video, options: option)
                        let items = list.objects(at: IndexSet(0..<list.count)).map { VideoItem(asset: $0) }
                        ob.onNext(items)
                    }
                    
                    if status != .authorized {
                        ob.onNext([])
                    }
                    ob.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

class PHVideoPlayerOption: PHVideoRequestOptions {
    override init() {
        super.init()
        isNetworkAccessAllowed = true
        deliveryMode = .fastFormat
        version = .current
    }
    
    static func requestItem(asset: PHAsset) -> Observable<AVPlayerItem> {
        return Observable.create { ob in
            PHImageManager
                .default()
                .requestAVAsset(forVideo: asset, options: PHVideoPlayerOption()) { asset, mix, info in
                    guard let asset = asset else {
                        return
                    }
                    let item = AVPlayerItem(asset: asset)
                    ob.onNext(item)
                    ob.onCompleted()
                }
            return Disposables.create()
        }
    }
}
