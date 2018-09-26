//
//  SettingCellView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SettingCellView: UIView {

	let title:UILabel	   = {
		let lb = UILabel()
		lb.textColor = UIColor.init(hexColor: "333333")
		lb.font = UIFont.systemFont(ofSize: 15)
		return lb
	}()
	let descLB:UILabel	   = {
		let lb = UILabel()
		lb.textColor = UIColor.init(hexColor: "999999")
		lb.font = UIFont.systemFont(ofSize: 15)
		return lb
	}()
	let arrow:UIImageView = UIImageView(image: #imageLiteral(resourceName: "me_rightArrow"))
	let line:UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		return view
	}()
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setUpViews()
		self.backgroundColor = UIColor.white
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	private func setUpViews() {
		

		self.addSubview(title)
		self.addSubview(descLB)
		self.addSubview(arrow)
		self.addSubview(line)
		
		
		title.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.leading.equalTo(self).offset(20)
		}
		arrow.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.trailing.equalTo(self).offset(-20)
		}
		descLB.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.trailing.equalTo(arrow.snp.leading).offset(-20)
		}
		
		line.snp.makeConstraints { (make) in
			make.leading.equalTo(self).offset(15)
			make.trailing.equalTo(self).offset(-15)
			make.bottom.equalTo(self)
			make.height.equalTo(1)
		}
	}

}


struct SettingModel {
	
	var name:String?
	var desc:String?
    var type:SettingCellType?
	var sepIsHidden:Bool?
}
