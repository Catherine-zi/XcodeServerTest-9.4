//
//  SettingTableViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

	var model:SettingModel? {
		didSet {
			
			settingCellView.title.text = model?.name
			settingCellView.descLB.text = model?.desc
			settingCellView.line.isHidden = (model?.sepIsHidden)!
			
			backView.layer.cornerRadius = 5
			backView.layer.masksToBounds = true
		}
	}
	
	private let settingCellView = SettingCellView()
	private let backView = UIView()
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setUpViews()
	}
	
	private func setUpViews() {
		
		backView.backgroundColor = UIColor.white
		
		self.contentView.addSubview(backView)
		backView.snp.makeConstraints { (make) in
			make.edges.equalTo(self.contentView)
		}
		
		backView.addSubview(settingCellView)
		settingCellView.snp.makeConstraints { (make) in
			make.edges.equalTo(backView)
		}
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		
		self.backgroundColor = self.superview?.backgroundColor
		self.contentView.backgroundColor = self.backgroundColor
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
