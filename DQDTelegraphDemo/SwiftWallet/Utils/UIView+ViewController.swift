//
//  UIView+ViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
	
	func viewController () -> (UIViewController){
		//1.通过响应者链关系，取得此视图的下一个响应者
		var next:UIResponder?
		guard let firstNext = self.next else {
			return UIViewController()
		}
		next = firstNext
		repeat {
			//2.判断响应者对象是否是视图控制器类型
			if ((next as?UIViewController) != nil) {
				return (next as! UIViewController)
			}else {
				next = next?.next
			}
		} while next != nil
		return UIViewController()
	}
	
}
