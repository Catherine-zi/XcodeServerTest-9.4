//
//  UITextView+link.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/6/29.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
	
	/// 添加链接文本（链接为空时则表示普通文本），且可加大指导字符串（默认font = 13）
	///
	/// - Parameters:
	///   - string: 文本
	///   - increaseStr: 需加大的字符串
	///   - withURLString: 链接
	///   - lineSpacing: 行间距
	func appendLinkString(string:String,
						  increaseStr:String?,
						  withURLString:String?,
						  lineSpacing:CGFloat) {
		// 原来的文本内容
		let attrString:NSMutableAttributedString = NSMutableAttributedString()
		attrString.append(self.attributedText)
		
		// 新增的文本内容（使用默认设置的字体样式）
		let attrs = [NSAttributedStringKey.font : self.font!,
					 NSAttributedStringKey.foregroundColor : self.textColor ?? UIColor.black]
		
		var appendString = NSMutableAttributedString(string: string, attributes:attrs)
		let range:NSRange = NSMakeRange(0, appendString.length)
		
		// 判断是否是链接文字
		if let urlStr = withURLString {
//			appendString.beginEditing()
			appendString.addAttribute(NSAttributedStringKey.link, value:urlStr, range:range)
//			appendString.endEditing()
			appendString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber.init(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), range: range)
		}

		
		
		
		// 合并新的文本
		attrString.append(appendString)
		
		// 设置合并后的文本
		self.attributedText = attrString
	}
}


