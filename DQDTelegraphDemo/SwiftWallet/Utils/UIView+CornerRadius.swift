//
//  UIView+CornerRadius.swift
//  PageMenuTest
//
//  Created by Avazu Holding on 2018/3/29.
//  Copyright © 2018年 Avazu Holding. All rights reserved.
//

import UIKit


@IBDesignable

class SWCornerRadiusView: UIView {
	
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet {
			layer.cornerRadius = cornerRadius
			layer.masksToBounds = cornerRadius > 0
		}
	}
}
