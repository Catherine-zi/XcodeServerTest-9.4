//
//  SwiftDiyHeader.swift
//  TestForAddCompiledFramework
//
//  Created by Avazu Holding on 2018/7/3.
//  Copyright © 2018年 Avazu Holding. All rights reserved.
//

import UIKit
import SnapKit

@objc class SwiftDiyHeader: MJRefreshStateHeader {

	let backView = UIView()
	let pointView = UIView()
	let headImageV = UIImageView()
	let statusLB = UILabel()
	let timeLB = UILabel()
	var stop = true
	let rotationV = UIImageView()
	let dateformatter:DateFormatter = DateFormatter()
	//MARK: 添加控件
	override func prepare() {
		super.prepare()
		mj_h = 58 //下拉之后视图的高度
		
		self.stateLabel.isHidden = true
		self.lastUpdatedTimeLabel.isHidden = true
		
		statusLB.font = UIFont.boldSystemFont(ofSize: 12)
		statusLB.textColor = UIColor.gray
		timeLB.font = UIFont.systemFont(ofSize: 9)
		timeLB.textColor = UIColor.gray
		
		headImageV.image = UIImage.init(named: "logogrey")
		statusLB.text = SWLocalizedString(key: "Pull down")
		statusLB.sizeToFit()
		
		let midding:CGFloat = 8
		let contentWidth:CGFloat = statusLB.bounds.size.width + midding + 44
		let leading:CGFloat = (SWScreen_width - contentWidth) * 0.5 - 10
		rotationV.image = UIImage.init(named: "rotation")
		rotationV.isHidden = true
		
		backView.addSubview(headImageV)
		backView.addSubview(statusLB)
		backView.addSubview(timeLB)
		backView.addSubview(rotationV)
		
		headImageV.snp.makeConstraints { (make) in
			make.centerY.equalTo(backView)
			make.leading.equalTo(backView).offset(leading)
			make.width.height.equalTo(44)
		}
		
		rotationV.snp.makeConstraints { (make) in
			make.centerY.equalTo(backView)
			make.leading.equalTo(backView).offset(leading)
			make.width.height.equalTo(44)
		}
		
		statusLB.snp.makeConstraints { (make) in
			make.leading.equalTo(headImageV.snp.trailing).offset(midding)
			make.bottom.equalTo(backView.snp.centerY).offset(-1)
		}
		timeLB.snp.makeConstraints { (make) in
			make.top.equalTo(backView.snp.centerY).offset(1)
			make.leading.equalTo(statusLB)
		}
		
//		headImageV.frame = CGRect(x: 102, y: 7, width: 44, height: 44)
//		rotationV.frame = headImageV.frame
		
//		statusLB.frame = CGRect(x: 102 + 44 + 10, y: 16, width: 100, height: 20)
//		timeLB.frame = CGRect(x: 102 + 44 + 10, y: 40, width: 100, height: 20)
		
	}
	
	//MARK: 设置控件的位置
	override func placeSubviews() {
		super.placeSubviews()
		
		backView.frame = self.bounds
		self.addSubview(backView)
	}
	
	//MARK: 监听控件的位置
	override var state: MJRefreshState {

		didSet {
			
			if state == .idle {
				self.headImageV.image = UIImage.init(named: "logogrey")
				self.stopAnimation()
				rotationV.isHidden = true
				statusLB.text = SWLocalizedString(key: "Pull down")
			}
			if state == .pulling {
				self.headImageV.image = UIImage.init(named: "logoblue")
				statusLB.text = SWLocalizedString(key: "Release")
			}
			if state == .refreshing {
//				self.headImageV.image = UIImage.init(named: "logobluebg")
				stop = false
				rotationV.isHidden = false
				startAnimation()
				statusLB.text = SWLocalizedString(key: "Loading")
			}
			
			setTimeLB()
			
			
		}
	}

	private func setTimeLB() {
		if (self.lastUpdatedTime != nil) {
			
			// 1.获得年月日
			let date = Date()
			
			let calendar = Calendar.current
			
			let year = calendar.component(.year, from: date)
			let day = calendar.component(.day, from: date)
			
		
			let lYear = calendar.component(.year, from: self.lastUpdatedTime)
			let lday = calendar.component(.day, from: self.lastUpdatedTime)
			
			let dateFormatter:DateFormatter = DateFormatter.init()
			var isToday:Bool = false
			if day == lday {
				isToday = true
				dateFormatter.dateFormat = " HH:mm"
			}else if year == lYear {
				dateFormatter.dateFormat = "MM-dd HH:mm"
			}else {
				dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
			}
			
			let time = dateFormatter.string(from: self.lastUpdatedTime)
			
			self.timeLB.text = SWLocalizedString(key: "LastedUpdate") + " " + (isToday ? SWLocalizedString(key: "Today") : "") + time
		}else {
			self.timeLB.text = SWLocalizedString(key: "NoRecord")
		}
			
		
	}
	
	private func startAnimation()  {
		if self.stop {
			return
		}
		// 1.创建动画
		let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
		
		// 2.设置动画的属性
		rotationAnim.fromValue = 0
		rotationAnim.toValue = M_PI * 2
		rotationAnim.repeatCount = MAXFLOAT
		rotationAnim.duration = 1.0
		// 这个属性很重要 如果不设置当页面运行到后台再次进入该页面的时候 动画会停止
		rotationAnim.isRemovedOnCompletion = false
		
		// 3.将动画添加到layer中
		rotationV.layer.add(rotationAnim, forKey: nil)
	}
	
//	func oppisoteDirection()  {
//		if self.stop {
//			return
//		}
//		UIView.animate(withDuration: 0.4, animations: {
//			let transform = CGAffineTransform.init(rotationAngle: CGFloat(-(M_PI / 3)))
//			self.pointView.transform = transform
//		}, completion: {(complete: Bool) in
//			if complete {
//				self.startAnimation()
//			}
//		})
//	}
	
	func stopAnimation()  {
		
		self.stop = true
		
		rotationV.layer.removeAllAnimations()
	}
}
