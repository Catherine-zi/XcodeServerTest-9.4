//
//  SWNotificationName.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation

enum SWNotificationName:String {
	
	case reloadAssetsType
	case addWalletSuccess//create or import
	case backWalletSucces//
    case deleteWalletSuccess
    case getRateSuccess
	
	case userLogin
	case userLogout

    case changeNotification

    case gainsColor
	case getRecommendGroup

	//dismiss transaction Vc
	case dismissTransactionVc
	case dismissSendDetailVc
    
    //currency setting change
    case currencySettingChange
    
    case costPriceChange
    
    case dismissAllSortingView
	
	//原生值 + 前缀
	var stringValue:String{
		return "SW" + rawValue
	}
	
	var notificationName:NSNotification.Name{
		return NSNotification.Name(stringValue)
	}
	
}

//自定义扩展
extension NotificationCenter {
	static func post(customeNotification name:SWNotificationName,object:Any? = nil){
		NotificationCenter.default.post(name: name.notificationName, object: object)
	}
}
