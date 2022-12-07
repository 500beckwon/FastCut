//
//  ScreenSize.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit

protocol ScreenSize {
    var screenWidth: CGFloat { get }
    var screenHeight: CGFloat { get }
}

extension ScreenSize {
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}
