//
//  VideoRecode+CoreDataProperties.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import Foundation
import CoreData
extension VideoRecode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoRecode> {
        return NSFetchRequest<VideoRecode>(entityName: "VideoRecode")
    }

    @NSManaged public var saveDate: String
    @NSManaged public var videoName: String
    @NSManaged public var videoData: Data
    
}
