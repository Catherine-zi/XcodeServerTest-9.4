//
//  AssetsTopSpecialView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsTopSpecialView: UIView {

	let popView:AssetsMoreBtnPopView = Bundle.main.loadNibNamed("AssetsMoreBtnPopView", owner: nil, options: nil)?.first as! AssetsMoreBtnPopView
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}


	@IBAction func clickScanBtn(_ sender: Any) {
	}
	@IBAction func clickAddBtn(_ sender: UIButton) {
		let vc:CreateWalletViewController = CreateWalletViewController()
		vc.hidesBottomBarWhenPushed = true
		self.viewController().navigationController?.pushViewController(vc, animated: true)
	}
	@IBAction func clickMoreBtn(_ sender: UIButton) {
		if popView.superview != nil {
			popView.removeFromSuperview()
		}else{
			popView.frame = CGRect.init(x: 100, y: 100, width: 157, height: 180)
			self.addSubview(popView)
		}
		
	}
	
}
