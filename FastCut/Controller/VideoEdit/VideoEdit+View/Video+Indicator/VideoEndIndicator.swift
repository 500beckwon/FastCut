//
//  VideoEndIndicator.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit

final class VideoEndIndicator: UIView {
    
    public var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        backgroundColor = .black
        let image = UIImage(named: "EndIndicator")
        
        
        imageView.image = image
        imageView.contentMode = .center
        self.addSubview(imageView)
        clipsToBounds = true
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
