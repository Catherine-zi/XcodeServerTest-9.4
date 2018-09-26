//
//  SelectMnemonicCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SelectMnemonicCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
		
    }
	
	private let titleSelectColor:UIColor = UIColor.white
	private let titleUnSelectColor:UIColor = UIColor.init(hexColor: "282828")
	private let bvSelectColor:UIColor = UIColor.init(red: 30, green: 89, blue: 245)
	private let bvUnSelectColor:UIColor = UIColor.white
	@IBOutlet weak var backView: SWCornerRadiusView!
	@IBOutlet weak var titleL: UILabel!
	
	var isSelectedCell:Bool = false {
		didSet {
			backView.backgroundColor = isSelectedCell ? bvSelectColor : bvUnSelectColor
			titleL.textColor = isSelectedCell ? titleSelectColor : titleUnSelectColor
		}
	}
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		self.contentView.backgroundColor = superview?.backgroundColor
	}
}
