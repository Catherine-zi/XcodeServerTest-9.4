//
//  SwiftWalletHeadImageManager.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation


class SwiftWalletHeadImageManager:NSObject {
	
	static let shared = SwiftWalletHeadImageManager()
	private override init() {
		super.init()
		
		let arr = UserDefaults.standard.object(forKey: "SwiftWalletHeadImage")
		if arr != nil {
			usedArr = arr as! [Int]
		}
	}
	
	private var usedArr:[Int] = []
	
	private static let sourceArr:[Int] = {
		
		var arr:[Int] = []
		for i in 1...10 {
			arr.append(i)
		}
		return arr
	}()
	
	//get walletImage （）
	func getImageName() -> String {
		
		//remove has used
		var randomArr = SwiftWalletHeadImageManager.sourceArr
		
		for i in usedArr {
			
			for (index, value) in randomArr.enumerated() {
				if value == i {
					randomArr.remove(at: index)
				}
			}

		}
		
		if randomArr.count > 0 {
			
			let random = arc4random() % (UInt32(randomArr.count))
			let value = randomArr[Int(random)]
			usedArr.append(value)
			UserDefaults.standard.set(usedArr, forKey: "SwiftWalletHeadImage")
			UserDefaults.standard.synchronize()
			return "wallet_logo_\(value)"
		}
		//random 1...10
		let random = arc4random() % 10
		return "wallet_logo_\(SwiftWalletHeadImageManager.sourceArr[Int(random)])"
	}
}

//create 1...12 random list
class CreateRandomList {
	
	class func getRandomList(randomCount:Int) -> [Int] {
		
		var random:[Int] = []
		for i in 0...randomCount-1 {
			random.append(i)
		}
		
		let forArr = (1...randomCount-1).reversed()
		for i in forArr {
			
			
			let changeCount = arc4random() % UInt32(i)
			
			//把随机数移到最后,并且把最后一个数字移到当前的位置，依次往前推移
			let lastCount = random[i]
			random[i] = random[Int(changeCount)]
			random[Int(changeCount)] = lastCount
			
		}
		return random
	}
}

//create random color for wallet (相邻不重复)
class CreateRandomColorForWallet {
	class func getRandomColorForWallet(randomCount:Int) -> [String] {
		
		if randomCount < 1 {
			return []
		}
		var colorArr:[String] = []
		
		var lastCount:Int = 10 //all color is five
		//assets_topBackView_1
		for _ in 1...randomCount {
			
			var random:Int?
			repeat {
				random = Int(arc4random() % 5) + 1
			} while (random == lastCount)
			
			lastCount = random!
			
			colorArr.append("assets_topBackView_\(lastCount)")
		}
		
		return colorArr
	}
    
    class func getColorForNewWallet(existWalletCount count: Int) -> String {
        let index: Int = count % 5 + 1
        return "assets_topBackView_\(index)"
    }
}
