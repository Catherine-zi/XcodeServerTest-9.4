//
//  SWAssetsTopView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/20.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SWAssetsTopView: UIView {

	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.setUpViews()
	}
	
	func setUpViews(){
		let btn = UIButton.init(frame: CGRect.init(x: 20, y: 20, width: 50, height: 50));
		btn.backgroundColor = UIColor.red
		btn.addTarget(self, action: #selector(addAssetsBtn(sender:)), for: UIControlEvents.touchUpInside)
		self.addSubview(btn)
	}
	@objc func addAssetsBtn(sender:UIButton) {
		
		let addAssetsVc:SWAddAssetsViewController = SWAddAssetsViewController()
		self.viewController().navigationController?.pushViewController(addAssetsVc, animated: true)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
