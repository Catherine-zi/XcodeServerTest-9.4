//
//  MeCellView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class MeCellView: UIView {

	let imageV:UIImageView = UIImageView()
	let title:UILabel	   = {
		let lb = UILabel()
		lb.textColor = UIColor.init(hexColor: "333333")
		lb.font = UIFont.boldSystemFont(ofSize: 15)
		return lb
	}()
	let notification:BadgeLabel = {
		let view = BadgeLabel()
		view.backgroundColor = UIColor.init(hexColor: "F96C6C")
        view.font = UIFont.systemFont(ofSize: 10)
        view.textColor = UIColor.white
        view.textAlignment = .center
		view.layer.cornerRadius = 7
		view.layer.masksToBounds = true
		return view
	}()
	let arrow:UIImageView = UIImageView(image: #imageLiteral(resourceName: "me_rightArrow"))
	let line:UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		return view
	}()
	let accountLb:UILabel = {
		let lb = UILabel()
		lb.textColor = UIColor.init(hexColor: "999999")
		lb.font = UIFont.systemFont(ofSize: 15)
		return lb
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
		
		self.addSubview(imageV)
		self.addSubview(title)
		self.addSubview(notification)
		self.addSubview(arrow)
		self.addSubview(line)
		self.addSubview(accountLb)
		
		imageV.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.leading.equalTo(self).offset(15)
		}
		title.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.leading.equalTo(imageV.snp.trailing).offset(15)
		}
		notification.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.leading.equalTo(title.snp.trailing).offset(15)
			make.height.equalTo(14)
            make.width.greaterThanOrEqualTo(14)
		}
		arrow.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.trailing.equalTo(self).offset(-20)
		}
		accountLb.snp.makeConstraints { (make) in
			make.centerY.equalTo(self)
			make.trailing.equalTo(arrow.snp.leading).offset(-10)
		}
		line.snp.makeConstraints { (make) in
			make.leading.equalTo(self).offset(15)
			make.trailing.equalTo(self).offset(-15)
			make.bottom.equalTo(self)
			make.height.equalTo(1)
		}
	}
}

class BadgeLabel: UILabel {
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
//        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
//        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
//                                          left: -textInsets.left,
//                                          bottom: -textInsets.bottom,
//                                          right: -textInsets.right)
//        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        return textRect.insetBy(dx: -4, dy: 0)
    }
    
    override func draw(_ rect: CGRect) {
//        let inset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.insetBy(dx: 4, dy: 0))
    }
}

struct MeCellModel {
	
	var imageName:String?
	var titleName:String?
	var notificationIsHidden:Bool?
    var notificationText:String?
	var sepIsHidden:Bool?
	var accountText:String?
	
}
