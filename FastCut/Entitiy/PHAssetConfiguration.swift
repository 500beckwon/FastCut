//
//  PHAssetConfiguration.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/11.
//


import Photos

final class PHAssetConfiguration: NSObject {
    private static var single = PHAssetConfiguration()
    
    @objc  class func `default`() -> PHAssetConfiguration {
        return PHAssetConfiguration.single
    }
    
    ///Default is 300x300
    var targetSize = PHAssetConstants.shared.targetSize
    
    var phFetchOptions: PHFetchOptions = PHAssetConstants.shared.phFetchOptions
    
    var imageRequestOptions: PHImageRequestOptions = PHAssetConstants.shared.imageRequestOptions
    
    var livePhotoRequestOptions: PHLivePhotoRequestOptions = PHAssetConstants.shared.livePhotoRequestOptions
    
    var videoRequestOptions: PHVideoRequestOptions = PHAssetConstants.shared.videoRequestOptions
    
    
    ///Constants
    private class PHAssetConstants {
        static let shared = PHAssetConstants()
        
        let targetSize = CGSize(width: 300, height: 300)
        
        var phFetchOptions: PHFetchOptions {
            let options = PHFetchOptions()
            return options
        }
        
        var imageRequestOptions: PHImageRequestOptions {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true
            return options
        }
        
        var livePhotoRequestOptions: PHLivePhotoRequestOptions {
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            return options
        }
        
        var videoRequestOptions:  PHVideoRequestOptions {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            return options
        }
        
    }
}
