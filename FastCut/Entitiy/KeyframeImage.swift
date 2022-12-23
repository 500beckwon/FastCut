//
//  KeyframeImage.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit
import AVFoundation

final class KeyframeImage: NSObject {
    
    /// image of keyframe
    var image: UIImage
    
    /// time of wanted
    var requestedTime: CMTime
    
    /// time of actual
    var actualTime: CMTime
    
    /// Init Method
    init(image: UIImage, requestedTime: CMTime, actualTime: CMTime) {
        self.image = image
        self.requestedTime = requestedTime
        self.actualTime = actualTime
    }
}
