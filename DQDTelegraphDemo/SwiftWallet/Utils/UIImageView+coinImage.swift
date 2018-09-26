//
//  UIImageView+sdImage.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/10.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
public extension UIImageView {
	
	func coinImageSet(urlStr: String?) {
		
		guard let str = urlStr else {
			self.image = UIImage(named: "placeholderIcon")
			return
		}
		if str.isEmpty {
			self.image = UIImage(named: "placeholderIcon")
			return
		}
		
		let newUrl = str.replacingOccurrences(of: " ", with: "%20")
		guard let url = URL(string: newUrl) else {
			return
		}
		self.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
	}
}
