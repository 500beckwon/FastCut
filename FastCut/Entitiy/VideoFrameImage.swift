//
//  VideoFrameImage.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import AVKit

// keyframe image model
class VideoFrameImage: NSObject {
    /// image of keyframe
    var image: UIImage?
    
    /// time of wanted
    var requestedTime: CMTime
    
    /// time of actual
    var actualTime: CMTime?
    
    /// Init Method
    init(image: UIImage? = nil, requestedTime: CMTime, actualTime: CMTime? = nil) {
        self.image = image
        self.requestedTime = requestedTime
        self.actualTime = actualTime
    }
}
