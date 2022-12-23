//
//  PHFetchOptions+Extensuon.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/11.
//

import Photos

extension PHFetchOptions {
    static func fetchOptions() -> PHFetchOptions {
        let option = PHFetchOptions()
        option.includeAssetSourceTypes = [.typeUserLibrary]
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return option
    }
}
