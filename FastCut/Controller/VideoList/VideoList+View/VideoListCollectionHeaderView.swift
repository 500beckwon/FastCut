//
//  VideoListCollectionHeaderView.swift
//  VideoEdit
//
//  Created by GNComms on 2022/02/07.
//

import Foundation
import UIKit

protocol VideoListCollectionHeaderViewDelegate {
    func didSelectedListupButton(button: UIButton)
    func didSelectedCameraButton()
}

final class VideoListCollectionHeaderView: UICollectionReusableView {
    var delegate: VideoListCollectionHeaderViewDelegate?
    
    var listupButton = UIButton(type: .system)
    var cameraButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        insertUI()
        basicSetUI()
        anchorUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func insertUI() {
        addSubview(listupButton)
        addSubview(cameraButton)
    }
    
    private func basicSetUI() {
        listupButtonBasicSet()
        cameraButtonBasicSet()
    }
    
    private func anchorUI() {
        listupButtonAnchor()
        cameraButtonAnchor()
    }
    
    private func listupButtonBasicSet() {
        listupButton.setTitle("비디오", for: .normal)
        listupButton.setTitle("비디오", for: .selected)
        listupButton.setTitleColor(.black, for: .normal)
        listupButton.setTitleColor(.black, for: .selected)
        
        listupButton.setImage(UIImage(named: "bi_chevron-left"), for: .selected)
        listupButton.setImage(UIImage(named: "bi_chevron-left"), for: .normal)
        
        listupButton.semanticContentAttribute = .forceRightToLeft
        listupButton.imageEdgeInsets.left = 10
        listupButton.backgroundColor = .clear
        listupButton.clipsToBounds = true
        listupButton.tintColor = .clear
        listupButton.addTarget(self, action: #selector(listupButtonTapped), for: .touchUpInside)
    }
    
    private func cameraButtonBasicSet() {
        cameraButton.setImage(UIImage(named: "VideoCamera"), for: .normal)
        cameraButton.backgroundColor = .black
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = 22
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    }
    
    private func listupButtonAnchor() {
        listupButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(22)
            make.height.equalTo(20)
            make.width.equalTo(62)
        }
    }
    
    private func cameraButtonAnchor() {
        cameraButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.right.equalTo(-16)
            make.top.equalTo(6)
        }
    }
    
    @objc func listupButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let rotate: CGFloat = sender.isSelected == true ? .pi : .pi * 2
       
        UIView.animate(withDuration: 0.2, delay: 0, options: []) { [weak sender] in
            sender?.imageView?.transform = CGAffineTransform(rotationAngle: rotate)
            sender?.imageView?.layoutIfNeeded()
        }
        delegate?.didSelectedListupButton(button: sender)
    }
    
    @objc func cameraButtonTapped() {
        delegate?.didSelectedCameraButton()
    }
}
