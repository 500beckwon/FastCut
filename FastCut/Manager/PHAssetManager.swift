//
//  PHAssetManager.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/11.
//

import Photos
import UIKit
import RxCocoa
import RxSwift

final class PHAssetManager {
    static let shared = PHAssetManager()
    private var storedPHImages: [PHImage] = []
    
    var configs = PHAssetConfiguration.default()
    
    var phFetchOptions: PHFetchOptions {
        get {
            configs.phFetchOptions
        }
        set {
            configs.phFetchOptions = newValue
        }
    }
    
    var imageRequestOptions: PHImageRequestOptions {
        get {
            configs.imageRequestOptions
        }
        set {
            configs.imageRequestOptions = newValue
        }
    }
    
    var targetSize: CGSize {
        get {
            configs.targetSize
        }
        set {
            configs.targetSize = newValue
        }
    }
    
    var livePhotoRequestOptions: PHLivePhotoRequestOptions {
        get {
            return configs.livePhotoRequestOptions
        }
        set {
            configs.livePhotoRequestOptions = newValue
        }
    }
    
    var videoRequestOptions: PHVideoRequestOptions {
        get {
            return configs.videoRequestOptions
        }
        set {
            configs.videoRequestOptions = newValue
        }
    }
}


extension PHAssetManager {
    func getPHAssets(by identifiers: [String]) -> [PHAsset] {
        var assets: [PHAsset] = []
        let results = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: phFetchOptions)
        results.enumerateObjects { phAsset, _, _ in
            assets.append(phAsset)
        }
        return assets
    }
    
    func getPHAssets(with mediaType: PHAssetMediaType) -> [PHAsset] {
        var allAssets: [PHAsset] = []
        PHAsset.fetchAssets(with: mediaType, options: phFetchOptions).enumerateObjects { asset, _, _ in
            allAssets.append(asset)
        }
        return allAssets
    }
    
    func getImages(assets: [PHAsset],
                   contentMode: PHImageContentMode = .aspectFit,
                   targetSize: CGSize? = nil,
                   completion: @escaping([PHImage]) -> Void) {
        let targetSize = targetSize ?? PHAssetManager.shared.targetSize
        var phImages: [PHImage] = []
        let group = DispatchGroup()
        for asset in assets {
            group.enter()
            if let phImage = self.getLocalImage(id: asset.localIdentifier, size: targetSize) {
                phImages.append(phImage)
                group.leave()
            } else {
                PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: self.imageRequestOptions, resultHandler: { image, _ in
                    guard let image = image else {
                        print("cannot get image")
                        group.leave()
                        return
                    }
                    phImages.append(PHImage(asset: asset, image: image))
                    self.storedPHImages.append(PHImage(asset: asset, image: image))
                    group.leave()
                })
            }
        }
        group.notify(queue: .main, execute: {
            completion(phImages)
        })
    }
    
    func getImage(asset: PHAsset,
                  contentMode: PHImageContentMode = .default,
                  targetSize: CGSize? = nil,
                  completion: @escaping(UIImage?) -> Void) {
        let targetSize = targetSize ?? PHAssetManager.shared.targetSize
        getImages(assets: [asset],
                  targetSize: targetSize,
                  completion: { image in
            completion(image.first?.image)
        })
    }
    
    func getLivePhoto(asset: PHAsset,
                      completion: @escaping(PHLivePhoto?) -> Void) {
        PHImageManager
            .default()
            .requestLivePhoto(for: asset,
                              targetSize: PHImageManagerMaximumSize,
                              contentMode: .aspectFill,
                              options: self.livePhotoRequestOptions,
                              resultHandler: { live, _ in
                completion(live)
        })
    }
    
    func getImageMaxSize(asset: PHAsset,
                         completion: @escaping (UIImage?) -> Void) {
        self.getImage(asset: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), completion: { image in
            completion(image)
        })
    }
    
    func getVideo(asset: PHAsset,
                  completion: @escaping (AVURLAsset?) -> Void) {
        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: self.videoRequestOptions) { avulAsset, _, _ in
            completion(avulAsset as? AVURLAsset)
        }
    }
    
    func requestImageData(for asset: PHAsset,
                          completion: @escaping(Data?) -> Void) {
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: self.imageRequestOptions, resultHandler: { data,_,_,_  in
            completion(data)
        })
    }
    
    func requestVideoData(for asset: PHAsset,
                          completion: @escaping(Data?) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: self.videoRequestOptions, resultHandler: { avasset, _, _ in
            if let avuAsset = avasset as? AVURLAsset {
                do {
                    let data = try Data(contentsOf: avuAsset.url)
                    completion(data)
                } catch {
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
            }
        })
    }
    
    func requestAVAsset(for asset: PHAsset,
                        completion: @escaping(AVAsset?, AVAudioMix?,
                                              [AnyHashable : Any]?) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: asset, options: self.videoRequestOptions, resultHandler: completion)
    }
    
    func requestAVPlayerItem(for asset: PHAsset) -> Driver<AVPlayerItem> {
        return Observable.create { [weak self] ob in
            guard let self = self else { fatalError() }
            PHImageManager
                .default()
                .requestAVAsset(forVideo: asset, options: self.videoRequestOptions) { asset, mix, info in
                    guard let asset = asset else {
                        return
                    }
                    let item = AVPlayerItem(asset: asset)
                    ob.onNext(item)
                    ob.onCompleted()
                }
            return Disposables.create()
        }.asDriver(onErrorDriveWith: Driver.empty())
    }
}

extension PHAssetManager {
    private func getLocalImage(id: String,
                               size: CGSize) -> PHImage? {
        if let phImage = self.storedPHImages.first(where: {$0.asset.localIdentifier == id}) {
            if phImage.image.size.width >= size.width || phImage.image.size.height >= size.height {
                return phImage
            }
        }
        return nil
    }
}
