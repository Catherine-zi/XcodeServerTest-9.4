//
//  GuideNoAssetsView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/17.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

@objc class GuideNoAssetsView: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		
	}
	
	@objc convenience init(frame: CGRect,btnRect:CGRect) {
		self.init(frame: frame)
		
		setupViews(btnRect: btnRect)
	}
	
	@objc var clickBtnClosure: (() -> Void)?
	
	private func setupViews(btnRect:CGRect) {
		
		self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		
		let watchBtn:UIButton = UIButton()
		watchBtn.setBackgroundImage(UIImage(named: "guide_butterwatch"), for: UIControlState.normal)
		watchBtn.frame = btnRect
		watchBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
		self.addSubview(watchBtn)
		
		let tipImageV:UIImageView = UIImageView(image: #imageLiteral(resourceName: "guide_down"))
		self.addSubview(tipImageV)
		
		let tip = UILabel()
		tip.text = SWLocalizedString(key: "guide_Assets_title")
		tip.textColor = UIColor.white
		tip.font = UIFont.boldSystemFont(ofSize: 18)
		self.addSubview(tip)
		
		tipImageV.snp.makeConstraints { (make) in
			make.centerX.equalTo(watchBtn)
			make.bottom.equalTo(watchBtn.snp.top).offset(-18)
		}
		
		tip.snp.makeConstraints { (make) in
			make.centerX.equalTo(watchBtn)
			make.bottom.equalTo(tipImageV.snp.top).offset(-12)
		}
	}
	@objc func clickBtn() {
		self.removeFromSuperview()
		
//		if self.clickBtnClosure != nil {
//			self.clickBtnClosure!()
//		}
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
