//
//  VideoItemViewModel.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/25.
//

import RxSwift
import UIKit

final class VideoItemViewModel {
    
    let videoItem: VideoItem
    
    init(with videoItem: VideoItem) {
        self.videoItem = videoItem
    }
    
    func getImage() -> Observable<UIImage?> {
        return Observable.create { ob in
            PHAssetManager
                .shared
                .getImage(asset: self.videoItem.asset, contentMode: .aspectFill) { image in
                    ob.onNext(image)
                }
            return Disposables.create()
        }
    }
}
