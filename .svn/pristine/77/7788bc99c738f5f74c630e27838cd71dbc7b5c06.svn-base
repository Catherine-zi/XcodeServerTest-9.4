//
//  UIFont+BoldItalic.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
extension UIFont {
	var bold: UIFont {
		return with(traits: .traitBold)
	} // bold
	
	var italic: UIFont {
		return with(traits: .traitItalic)
	} // italic
	
	var boldItalic: UIFont {
		return with(traits: [.traitBold, .traitItalic])
	} // boldItalic
	
	
	func with(traits: UIFontDescriptorSymbolicTraits) -> UIFont {
		guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
			return self
		} // guard
		
		return UIFont(descriptor: descriptor, size: 0)
	} // with(traits:)
} // extension
