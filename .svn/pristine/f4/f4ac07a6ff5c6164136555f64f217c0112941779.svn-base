//
//  UIColor+RGB.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import UIKit


extension UIColor{
	
	convenience init(hexColor: String) {
		
		var red:UInt32 = 0,green:UInt32 = 0,blue:UInt32 = 0
		
		// 分别转换进行转换
		Scanner(string: hexColor[0..<2]).scanHexInt32(&red)
		
		Scanner(string: hexColor[2..<4]).scanHexInt32(&green)
		
		Scanner(string: hexColor[4..<6]).scanHexInt32(&blue)
		
		self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
	}
}

extension UIColor{
	convenience init(red:CGFloat,green:CGFloat,blue:CGFloat){
		self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
	}
}

private extension String {
	
	/// String使用下标截取字符串
	subscript (r: Range<Int>) -> String {
		get {
			let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
			let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
			
			return String(self[startIndex..<endIndex])
		}
	}
}

let mainColor = UIColor.init(hexColor: "356AF6")//APP 主色调
