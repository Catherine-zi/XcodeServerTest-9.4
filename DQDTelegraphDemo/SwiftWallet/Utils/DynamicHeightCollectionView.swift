//
//  DynamicHeightCollectionView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/10.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {

	override func layoutSubviews() {
		super.layoutSubviews()
		
		if self.bounds.height != self.collectionViewLayout.collectionViewContentSize.height {
			self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: self.collectionViewLayout.collectionViewContentSize.height)
		} 
	}

}

//靠左布局
class UICollectionViewLeftFlowLayout: UICollectionViewFlowLayout {
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attrsArry = super.layoutAttributesForElements(in: rect) else {
			return nil
		}
		for i in 0..<attrsArry.count {
			if i != attrsArry.count-1 {
				let curAttr = attrsArry[i]
				let nextAttr = attrsArry[i+1]
				if curAttr.frame.minY == nextAttr.frame.minY {
					if nextAttr.frame.minX - curAttr.frame.maxX > minimumInteritemSpacing{
						var frame = nextAttr.frame
						let x = curAttr.frame.maxX + minimumInteritemSpacing
						frame = CGRect(x: x, y: frame.minY, width: frame.width, height: frame.height)
						nextAttr.frame = frame
					}
				}
			}
		}
		return attrsArry
	}
}
