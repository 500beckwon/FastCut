//
//  Data+Extension.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit

extension Data {
    func getDataMegaCount() -> Int {
        print("There were \(count) bytes")
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file

        let string = bcf.string(fromByteCount: Int64(count))
        let split = string.split(separator: ".")
        print(string, split)
        guard split.count > 0 else { return 0 }
        if let volume = Int("\(split[0])") {
            return volume
        } else {
            return 0
        }
    }
}
