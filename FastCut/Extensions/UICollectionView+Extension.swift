//
//  UICollectionViewExtension.swift
//  Picple
//
//  Created by Mac mini on 2020/10/06.
//  Copyright © 2020 Choi. All rights reserved.
//

import UIKit
extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(_: Cell.Type) {
        register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func registerHeaderCell<Header: UICollectionReusableView>(_: Header.Type, kind: String = UICollectionView.elementKindSectionHeader) {
        register(Header.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: Header.reuseIdentifier)
    }
    
    func dequeueCell<Cell: UICollectionViewCell>(indexPath: IndexPath) -> Cell {
        return self.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
    
    func dequeueSupplementaryCell<Cell: UICollectionReusableView>(indexPath: IndexPath) -> Cell {
        return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
    
    func initCellForItem<Cell: UICollectionViewCell>(indexPath: IndexPath) -> Cell {
        return self.cellForItem(at: indexPath) as! Cell
    }
    
    var rowWidth: CGFloat {
        guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return safeAreaLayoutGuide.layoutFrame.width
                - contentInset.left
                - contentInset.right
        }
        
        let sectionInset = collectionViewLayout.sectionInset
        return safeAreaLayoutGuide.layoutFrame.width
            - sectionInset.left
            - sectionInset.right
            - contentInset.left
            - contentInset.right
    }
}

extension UICollectionReusableView: Reusable {
    
}
