//
//  GuideTabBarView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/16.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

@objc class GuideTabBarView: UIView {

	@objc convenience init(frame: CGRect,iconCenter: CGPoint) {
		self.init(frame: frame)
		setupViews(iconCenter: iconCenter)
		
		//储存状态
		BeginningGuideManager.shared.storeValue()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
	}
	
	@objc var clickBtnClosure: (() -> Void)?
	
	private func setupViews(iconCenter: CGPoint) {
		
		self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		
		//btn
		let tabBtn: UIButton = UIButton()
		
		let radius:CGFloat = 31
		tabBtn.addTarget(self, action: #selector(didClickBtn(sender:)), for: UIControlEvents.touchUpInside)
		if SWScreen_height == 812.0 {
			tabBtn.frame = CGRect(origin: CGPoint(x: iconCenter.x - radius, y: SWScreen_height - radius * 2 - iPhoneXBottomHeight), size: CGSize(width: radius * 2, height: radius * 2))
		}else {
			tabBtn.frame = CGRect(origin: CGPoint(x: iconCenter.x - radius, y: SWScreen_height - radius * 2), size: CGSize(width: radius * 2, height: radius * 2))
		}
		
		tabBtn.setImage(UIImage.init(named: "assets_tabbarIcon_selected"), for: UIControlState.normal)
		tabBtn.backgroundColor = UIColor.white
		tabBtn.layer.cornerRadius = radius
		tabBtn.layer.masksToBounds = true
		self.addSubview(tabBtn)
		
		//detailTip
		let detailTipLB = UILabel()
		detailTipLB.text = SWLocalizedString(key: "guide_tabBar_subtitle")
		detailTipLB.textColor = UIColor.white
		detailTipLB.font = UIFont.systemFont(ofSize: 12)
		detailTipLB.textAlignment = .center
		detailTipLB.numberOfLines = 0
		self.addSubview(detailTipLB)
		
		//tip
		let tipTitle = UILabel()
		tipTitle.text = SWLocalizedString(key: "guide_tabBar_title")
		tipTitle.textColor = UIColor.white
		tipTitle.font = UIFont.boldSystemFont(ofSize: 18)
		tipTitle.numberOfLines = 0
		tipTitle.textAlignment = .center
		self.addSubview(tipTitle)
		
		let tipImageV = UIImageView(image: #imageLiteral(resourceName: "guide_down"))
		self.addSubview(tipImageV)
		
		tipImageV.snp.makeConstraints { (make) in
			make.centerX.equalTo(tabBtn)
			make.bottom.equalTo(tabBtn.snp.top).offset(-30)
		}
		
		detailTipLB.snp.makeConstraints { (make) in
			make.centerX.width.equalTo(self)
			make.bottom.equalTo(tipImageV.snp.top).offset(-30)
		}
		tipTitle.snp.makeConstraints { (make) in
			make.centerX.width.equalTo(self)
			make.bottom.equalTo(detailTipLB.snp.top).offset(-7)
		}
	}
	
	@objc func didClickBtn(sender: UIButton) {
		self.removeFromSuperview()
		
		if self.clickBtnClosure != nil {
			self.clickBtnClosure!()
		}
		
		
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

}
