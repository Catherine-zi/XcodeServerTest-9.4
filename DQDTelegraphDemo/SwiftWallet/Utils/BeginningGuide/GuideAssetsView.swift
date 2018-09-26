//
//  GuideAssetsView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/20.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

@objc class GuideAssetsView: UIView {

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
		
		let rightBtn = UIButton()
		rightBtn.setBackgroundImage(#imageLiteral(resourceName: "guide_buttermore"), for: UIControlState.normal)
		rightBtn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
		self.addSubview(rightBtn)
		
		let imageV = UIImageView(image: #imageLiteral(resourceName: "guide_right"))
		self.addSubview(imageV)
		
		let tipTitle = UILabel()
		tipTitle.text = SWLocalizedString(key: "guide_Assets_title")
		tipTitle.textColor = UIColor.white
		tipTitle.font = UIFont.systemFont(ofSize: 18)
		self.addSubview(tipTitle)
		
		let subTitle = UILabel()
		subTitle.textColor = UIColor.white
		subTitle.text = SWLocalizedString(key: "guide_Assets_subTitle")
		subTitle.font = UIFont.systemFont(ofSize: 12)
		self.addSubview(subTitle)
		
		rightBtn.snp.makeConstraints { (make) in
			make.right.equalTo(self)
			make.top.equalTo(self).offset(SWStatusBarH)
			make.width.height.equalTo(62)
		}
		imageV.snp.makeConstraints { (make) in
			make.right.equalTo(rightBtn.snp.left)
			make.top.equalTo(rightBtn.snp.bottom)
			make.width.height.equalTo(36)
		}
		tipTitle.snp.makeConstraints { (make) in
			make.top.equalTo(imageV.snp.bottom)
			make.right.equalTo(imageV.snp.left).offset(-10)
		}
		subTitle.snp.makeConstraints { (make) in
			make.top.equalTo(tipTitle.snp.bottom).offset(6)
			make.centerX.equalTo(tipTitle)
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
