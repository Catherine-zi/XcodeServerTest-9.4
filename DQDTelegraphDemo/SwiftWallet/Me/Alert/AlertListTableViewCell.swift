//
//  AlertListTableViewCell.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/9/4.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class AlertListTableViewCell: UITableViewCell {

	private let backView = UIView()
	private let imageV = UIImageView()
	private let titleLB = UILabel()
	private let subTitleLB = UILabel()
    
    var longPressActionBlock: (() -> ())?
    
	var model:AlertDetailStruct? {
		didSet {
			imageV.coinImageSet(urlStr: model?.icon)
			
			if let pair = model?.pair,let exchange = model?.exchange,
				let abovePrice = model?.above_price,let belowPrice = model?.below_price,
				let decimalPrice = Decimal(string: abovePrice), let decimalBelowPrice = Decimal(string: belowPrice){

				titleLB.text = pair + "(" + exchange + ")"
				let coins = pair.components(separatedBy: "/")
				
				if let _ = coins.last {
                    var hintStr = ""
                    if decimalPrice != 0 {
                        hintStr += ("≥" + decimalPrice.description)
                    }
                    if decimalBelowPrice != 0 {
                        if hintStr.count > 0 {
                            hintStr += " OR "
                        }
                        hintStr += ("≤" + decimalBelowPrice.description)
                    }
                    subTitleLB.text = hintStr
//                    subTitleLB.text = ">=" + decimalPrice.description + " " + coin + " OR " + "<=" + decimalBelowPrice.description
				}
				
			}
		}
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		
		backView.backgroundColor = UIColor.white
		backView.layer.cornerRadius = 4
		backView.layer.shadowRadius = 4
		backView.layer.shadowColor = UIColor.init(hexColor: "EBEBEB").cgColor
		backView.layer.shadowOffset = CGSize(width: 0, height: 5)
		backView.layer.shadowOpacity = 0.7
		backView.layer.masksToBounds = false
		self.contentView.addSubview(backView)
		backView.snp.makeConstraints { (make) in
			make.top.bottom.equalTo(self.contentView)
			make.left.equalTo(self.contentView).offset(15)
			make.right.equalTo(self.contentView).offset(-15)
		}
		//imageV
		imageV.layer.borderColor = UIColor.init(hexColor: "f1f1f1").cgColor
		imageV.layer.borderWidth = 1
		imageV.layer.cornerRadius = 4
		
		titleLB.font = UIFont.boldSystemFont(ofSize: 15)
		titleLB.textColor = UIColor.init(hexColor: "333333")
//		titleLB.text = "1321323e32 "
		
		subTitleLB.font = UIFont.systemFont(ofSize: 12)
		subTitleLB.textColor = UIColor.init(hexColor: "999999")
//		subTitleLB.text = "2322332"
		
		backView.addSubview(imageV)
		backView.addSubview(titleLB)
		backView.addSubview(subTitleLB)
		
		imageV.snp.makeConstraints { (make) in
			make.centerY.equalTo(backView)
			make.left.equalTo(backView).offset(15)
			make.width.height.equalTo(40)
		}
		titleLB.snp.makeConstraints { (make) in
			make.bottom.equalTo(backView.snp.centerY)
			make.left.equalTo(imageV.snp.right).offset(15)
			make.right.equalTo(backView).offset(-15)
		}
		subTitleLB.snp.makeConstraints { (make) in
			make.top.equalTo(backView.snp.centerY)
			make.left.right.equalTo(titleLB)
		}
        
        let long: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(long:)))
        self.contentView.addGestureRecognizer(long)
	}
    
    @objc private func longPress(long: UILongPressGestureRecognizer){
        
        if longPressActionBlock != nil {
            longPressActionBlock!()
        }
    }
	
	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		self.contentView.backgroundColor = newSuperview?.backgroundColor
	}
}
