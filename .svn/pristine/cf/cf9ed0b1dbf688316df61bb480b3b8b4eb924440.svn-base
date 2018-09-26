//
//  CreateWalletErrorTipsView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit


let errorTipH:CGFloat = 25
let errorColor:UIColor = UIColor.init(hexColor: "f96c6c")

class CreateWalletErrorTipsView: UIView {

	let errorTipLB:UILabel = UILabel()
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		
		errorTipLB.textColor = UIColor.init(hexColor: "f96c6c")
		errorTipLB.font = UIFont.systemFont(ofSize: 12)
		self.addSubview(errorTipLB)
		
		errorTipLB.snp.makeConstraints { (make) in
			make.top.equalTo(self).offset(10)
			make.leading.equalTo(self).offset(16)
			make.trailing.equalTo(self)
		}
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
