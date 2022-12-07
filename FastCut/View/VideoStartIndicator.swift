//
//  VideoStartIndicator.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import UIKit

class VideoStartIndicator: UIView {
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        let image = UIImage(named: "StartIndicator")
        self.addSubview(imageView)
        backgroundColor = .black
       // imageView.frame = self.bounds
        imageView.image = image
        imageView.contentMode = .center
        clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
