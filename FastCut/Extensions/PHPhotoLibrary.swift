//
//  PHPhotoLibrary.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/25.
//

import Photos
import RxSwift
import RxCocoa

//https://github.com/oRhino/RxSwiftStudy/blob/75b7d6f207af171c7d46a8958bbb3b09db19efca/RXSwiftDemo/Observable%26Subject/PhotosViewController.swift

extension PHPhotoLibrary {
    static var authorized: Observable<Bool> {
        
        return Observable.create { ob in

            if authorizationStatus() == .authorized {
                ob.onNext(true)
                ob.onCompleted()
            } else {
                ob.onNext(false)
                requestAuthorization({ (status) in
                    ob.onNext(status == .authorized)
                    ob.onCompleted()
                })
            }
            return Disposables.create()
        }
    }
}
