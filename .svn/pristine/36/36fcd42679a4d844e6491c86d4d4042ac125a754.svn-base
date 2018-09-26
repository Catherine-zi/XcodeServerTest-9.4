//
//  SwiftDiyLoading.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/23.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

class SwiftDiyLoading: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setUpViews()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private let rotationV = UIImageView(image: #imageLiteral(resourceName: "rotation"))
	private func setUpViews() {
		
		let centerV = UIImageView(image: #imageLiteral(resourceName: "logoblue"))
		self.addSubview(rotationV)
		self.addSubview(centerV)
		
		rotationV.snp.makeConstraints { (make) in
			make.center.equalTo(self)
		}
		centerV.snp.makeConstraints { (make) in
			make.center.equalTo(self)
		}
		
	}
	
	func startLoading() {
		
		// 1.创建动画
		let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
		
		// 2.设置动画的属性
		rotationAnim.fromValue = 0
		rotationAnim.toValue = (Double.pi) * 2
		rotationAnim.repeatCount = MAXFLOAT
		rotationAnim.duration = 1.0
		// 这个属性很重要 如果不设置当页面运行到后台再次进入该页面的时候 动画会停止
		rotationAnim.isRemovedOnCompletion = false
		
		// 3.将动画添加到layer中
		rotationV.layer.add(rotationAnim, forKey: nil)
	}
	func stopLoading() {
		
		rotationV.layer.removeAllAnimations()
		
	}
	
}
