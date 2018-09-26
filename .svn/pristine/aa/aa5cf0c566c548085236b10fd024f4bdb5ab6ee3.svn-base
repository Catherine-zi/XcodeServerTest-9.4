//
//  CustomPagingSizeLayout.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/7/10.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class CustomPagingSizeLayout: UICollectionViewFlowLayout {

	override func prepare() {
		super.prepare()
		
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		print("rect = \(rect)")
		return super.layoutAttributesForElements(in: rect)
	}
	
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		
		let collectionViewSize = self.collectionView!.bounds.size
		let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width * 0.5
		
		let proposedRect = self.collectionView!.bounds
		
		// Comment out if you want the collectionview simply stop at the center of an item while scrolling freely
		// proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
		
		var candidateAttributes: UICollectionViewLayoutAttributes?
		for attributes in self.layoutAttributesForElements(in: proposedRect)! {
			// == Skip comparison with non-cell items (headers and footers) == //
			if attributes.representedElementCategory != .cell {
				continue
			}
			
			
			// Get collectionView current scroll position
			let currentOffset = self.collectionView!.contentOffset
			
			// Don't even bother with items on opposite direction
			// You'll get at least one, or else the fallback got your back
			if (attributes.center.x < (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x > (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
				continue
			}
			
			
			// First good item in the loop
			if candidateAttributes == nil {
				candidateAttributes = attributes
				continue
			}
			
			
			// Save constants to improve readability
			let lastCenterOffset = candidateAttributes!.center.x - proposedContentOffsetCenterX
			let centerOffset = attributes.center.x - proposedContentOffsetCenterX
			
			if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
				candidateAttributes = attributes
			}
		}
		
		if candidateAttributes != nil {
			// Great, we have a candidate
			return CGPoint(x: candidateAttributes!.center.x - collectionViewSize.width * 0.5, y: proposedContentOffset.y)
		} else {
			// Fallback
			return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
		}
		
		
	}
	
	
	// Apple建议要重写这个方法, 因为某些情况下(delete insert...)系统可能需要调用这个方法来布局
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return super.layoutAttributesForItem(at: indexPath)
		
	}
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
}
