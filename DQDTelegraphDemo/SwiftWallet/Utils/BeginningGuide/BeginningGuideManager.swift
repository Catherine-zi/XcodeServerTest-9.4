//
//  BeginningGuideManager.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/8/16.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import Foundation
import UIKit

@objc class BeginningGuideManager:NSObject {
	
	@objc static let shared = BeginningGuideManager()
	private let userDefaultKey = "BeginningGuideUserDefaultKe"
	@objc var isNeedShow:Bool = false
	private override init() {
		 super.init()
		
		let value = true//UserDefaults.standard.bool(forKey: userDefaultKey) //关闭新手引导
		
		if value {
			isNeedShow = false
		}else {
			isNeedShow = true
		}
	}
	
	@objc func storeValue() {
		
		UserDefaults.standard.set(true, forKey: userDefaultKey)
		UserDefaults.standard.synchronize()
		
		isNeedShow = false
	}
	
}
