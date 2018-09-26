//
//  AssetsAPI.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/28.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya

let AssetsAPIProvider = MoyaProvider<AssetsAPI>()

public enum AssetsAPI {
	case getTokens//get eth tokens
    case addLog(address: String, asset: String, watch: String)
}

extension AssetsAPI: TargetType {
	public var baseURL: URL {
		return SwiftWalletBaseURL
	}
	
	public var path: String {
		switch self {
		case .getTokens:
			return "/index/getTokens"
//        default:
//            return ""
        case .addLog(_, _, _):
            return "/wallet/addlog"
        }
    }
	
	public var method: Moya.Method {
		return .post
	}
	
	public var sampleData: Data {
		return "{}".data(using: String.Encoding.utf8)!
	}
	
	public var task: Task {
        switch self {
        case .getTokens:
            if isTest {
                return .requestParameters(parameters: ["no_encrypt":1,"debug":1], encoding: URLEncoding.default)
            }else{
                let params: [String: Any] = [:]
                let data:Data = Data.init(encryptionParams: params)
                return .requestData(data)
            }
        case .addLog(let address, let asset, let watch):
            var params: [String: Any] = [:]
            params["wallet_address"] = address
            params["assets"] = asset
            params["watch"] = watch
            params["platform"] = "2"
//            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            let data:Data = Data.init(encryptionParams: params)
            return .requestData(data)
        }
	}
	
	public var headers: [String : String]? {
		return nil
	}
}

struct AssetsGetTokensModel:Codable {
	
	var msg:String?
	var data:[AssetsTokensModel]?
	var code:Int
}

public struct AssetsTokensModel:Codable {
	
	
	var symbol:String?
	var contractName:String?
	var iconUrl:String?
	var contractAddress:String?
	var decim:String?
	var saler:String?
	var gas:String?
    var balance:Decimal?
    var balanceInLegal:Decimal?
    var costPrice:Decimal? // 不用
    var cost:Decimal?
    var costCurrency:SwiftExchanger.SwiftCurrency?
	
	var isSelected:Bool?//for addAssets show cell
//
	enum CodingKeys:String, CodingKey {
		case symbol
		case contractName = "contract_name"
		case iconUrl
		case contractAddress = "contract_address"
		case decim = "decimals"
		case saler
		case gas
		case isSelected = "is_selected"
        case balance
        case balanceInLegal = "balance_in_legal"
        case costPrice = "cost_price"
        case costCurrency = "cost_currency"
        case cost
	}
	
}

