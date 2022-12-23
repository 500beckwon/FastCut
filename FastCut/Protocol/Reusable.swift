//
//  Reusable.swift
//  Picple
//
//  Created by Mac mini on 2020/10/06.
//  Copyright © 2020 Choi. All rights reserved.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}


