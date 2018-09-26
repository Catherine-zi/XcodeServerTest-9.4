//
//  AllDetailDiyButton.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AllDetailDiyButton: UIButton {

//	var isNeedShowMore = false
//	var isShowMore = false
    override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let image:UIImage = UIImage.init(color: UIColor.init(hexColor: "356AF6"))!
		let normalImage:UIImage = UIImage.init(color: UIColor.init(hexColor: "F2F2F2"))!
		self.setBackgroundImage(image, for: .selected)
		self.setBackgroundImage(image, for: .highlighted)
		self.setBackgroundImage(normalImage, for: .normal)
		self.setTitleColor(UIColor.init(hexColor: "FFFFFF"), for: .selected)
		self.setTitleColor(UIColor.init(hexColor: "999999"), for: .normal)
		
		self.titleLabel?.font = UIFont.systemFont(ofSize: 10)
		self.layer.cornerRadius = 4
		self.layer.masksToBounds = true
    }
	
	override var isSelected: Bool{
		didSet {
			self.titleLabel?.font = isSelected ? UIFont.boldSystemFont(ofSize: 10) : UIFont.systemFont(ofSize: 10)
		}
	}
	
	
}
