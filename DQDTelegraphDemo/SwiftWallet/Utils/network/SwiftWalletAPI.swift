//
//  SwiftWalletAPI.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/8.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya

let SwiftWalletProvider = MoyaProvider<SwiftWalletAPI>()

public enum SwiftWalletAPI {
	
	case exchange
	case balance
}

extension SwiftWalletAPI:TargetType {
	public var baseURL: URL {
		return BitcoinBaseURL
	}
	
	public var path: String {
		switch self {
		case .exchange:
			return "/market/exchanges"
		case .balance:
			return "get_balance"
		
		}
	}
	
	public var method: Moya.Method {
		return .post
	}
	
	public var sampleData: Data {
		return "{}".data(using: String.Encoding.utf8)!
	}
	
	public var task: Task {
		return .requestParameters(parameters: [ "user_address": "my3CkK5U8U79bCx6wj8hfcw7zfXrEHk5e2"], encoding: JSONEncoding.default)
	}
	
	public var headers: [String : String]? {
		return nil
	}
	
	
}
