//
//  ExpansionView.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/8.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import Foundation

enum KLineMinType:String {
	
	case min
	case oneMin
	case fiveMin
	case fifteenMin
	case thirtyMin
	case oneHour
	case twoHour
	case fourHour
	case sixHour
	
}
protocol KLineDelegate: class {
	func clickTimeType(type:KLineMinType, isHourExpanV:Bool)
}

class ExpansionView:UIView {
	
	
	var arr:Array<String>
	var topTitle:String
	let title = UILabel()
	
	convenience init(btnArr:Array<String>,title:String, frame: CGRect) {
		
		self.init(frame: frame)
		
		self.arr = btnArr
		self.topTitle = title
		
		self.backgroundColor = UIColor.white//init(hexColor: "F2F2F2")
		self.layer.cornerRadius = 6
		self.layer.shadowRadius = 6
		self.layer.shadowColor = UIColor.init(hexColor: "ebebeb").cgColor
		self.layer.shadowOffset = CGSize(width: 0, height: 5)
		self.layer.shadowOpacity = 0.7
		self.layer.masksToBounds = false
		setUpView()
	}
	
	override init(frame: CGRect) {
		
		self.arr = []
		self.topTitle = ""
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	weak var delegate:KLineDelegate?
	let pullImage = UIImageView(image: #imageLiteral(resourceName: "iconPULL"))//UIImage.init(named: "kLine_down"))
	
	func hiddenExpansion() {
		
		let frame = self.frame
		UIView.animate(withDuration: 0.3) {
			self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0)
			self.pullImage.image = #imageLiteral(resourceName: "iconBlue")//UIImage.init(named: "kLine_pull")
		}
	}
	func showMore() {
		let frame = self.frame
		self.isHidden = false
		UIView.animate(withDuration: 0.3) {
			self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: btnH * CGFloat(minArr.count - 1))
			
			self.pullImage.image = #imageLiteral(resourceName: "iconPULL")//UIImage.init(named: "kLine_down")
			self.layer.cornerRadius = cornerRadius
			self.layer.masksToBounds = true
			self.superview?.bringSubview(toFront: self)
		}
	}
	//MARK: 为了适配用于全屏状态时，改变选中的按钮状态
	func changeBtnStatus(tag: Int) {
	
		for btn in self.subviews {
			if btn.isKind(of: UIButton.classForCoder())  {
				
				let button:UIButton = btn as! UIButton
				//btn
				if btn.tag == tag {
					button.isSelected = true
					button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
				}else {
					button.isSelected = false
					button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
				}
			}
		}
		hiddenExpansion()
	}
	@objc func clickBtn(sender:UIButton){
		
		changeBtnStatus(tag: sender.tag)

		if self.delegate != nil {
			
			var type:KLineMinType
			let flag:Bool = (self.topTitle == minArr.first!)
			switch sender.tag {
			case 0 :
				type = flag ? .oneMin : .oneHour
			case 1 :
				type = flag ? .fiveMin : .twoHour
			case 2 :
				type = flag ? .fifteenMin : .fourHour
			case 3 :
				type = flag ? .thirtyMin : .sixHour
			default:
				type = .oneMin
			}
			title.text = arr[sender.tag].uppercased()
			self.delegate?.clickTimeType(type: type,isHourExpanV: !flag)
		}
	}
	@objc func tap(sender:UITapGestureRecognizer) {
		
        if pullImage.image == #imageLiteral(resourceName: "iconPULL") {//UIImage.init(named: "kLine_down"){
			//recover
			hiddenExpansion()
		} else {
			showMore()
		}
	}
	
	private func setUpView() {

		let viewH:CGFloat = btnH
		let viewW:CGFloat = timeTypeBtnW
		let viewX:CGFloat = 0
		var viewY:CGFloat = 0
        
		//other
		
		for (index,value) in arr.enumerated() {
			
			viewY = CGFloat(index) * viewH
			
			let btn = UIButton()
			btn.tag = index
			btn.setTitle(value.uppercased(), for: .normal)
			btn.setTitleColor(UIColor.init(hexColor: "356AF6"), for: .selected)
			btn.setTitleColor(UIColor.init(hexColor: "999999"), for: .normal)
			btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
			btn.addTarget(self, action: #selector(clickBtn(sender:)), for: UIControlEvents.touchUpInside)
//            btn.backgroundColor = self.backgroundColor
			btn.frame = CGRect(x: viewX, y: viewY, width: viewW, height: viewH)
			self.addSubview(btn)
			
			if index != 3 {
				let line = UIView()
				line.backgroundColor = UIColor.init(hexColor: "dddddd")
				line.alpha = 0.4
				line.frame = CGRect(x: 8, y: viewY + viewH - 1 , width: viewW - 16, height: 1)
				self.addSubview(line)
				self.bringSubview(toFront: line)
			}
		}
	}
	
}
