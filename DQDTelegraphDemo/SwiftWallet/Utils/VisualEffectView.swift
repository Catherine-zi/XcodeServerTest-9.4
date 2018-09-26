//
//  VisualEffectView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation

class VisualEffectView {
	
	class func visualEffectView(frame:CGRect) ->UIVisualEffectView {

		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
		let blurView = UIVisualEffectView(effect: blurEffect)
		
		blurView.frame = frame
		
		return blurView
	}
	
	static let subFrame:CGRect = CGRect(x: 15, y: 160, width: SWScreen_width - 30, height: 270)
}
