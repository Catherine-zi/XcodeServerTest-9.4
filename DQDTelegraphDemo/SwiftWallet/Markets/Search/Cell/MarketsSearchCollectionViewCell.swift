//
//  MarketsSearchCollectionViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/10.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class MarketsSearchCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

	@IBOutlet weak var title: UILabel!
	
	override func didMoveToSuperview() {
		superview?.didMoveToSuperview()
		
		self.contentView.backgroundColor = superview?.backgroundColor
	}
}
