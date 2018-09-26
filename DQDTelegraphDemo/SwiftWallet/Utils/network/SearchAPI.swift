//
//  SearchAPI.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/3.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya

let SearchAPIProvider = MoyaProvider<SearchAPI>()

public enum SearchAPI {
	case searchCurrencyRecommend
	case searchMarket(String, Int, Int)
    case searchSymbol(String, Int, Int)
    case searchExchangePair(String, Int, Int)

}

extension SearchAPI:TargetType {
	public var baseURL: URL {
		return SwiftWalletBaseURL
	}
	
	public var path: String {
		switch self {
		case .searchCurrencyRecommend:
			return "/search/currencyRecommend"
        case .searchMarket(_):
            return "/search/market"
        case .searchSymbol(_):
            return "/search/symbol"
        case .searchExchangePair(_):
            return "/search/exchangePair"

//        default:
//            return ""
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
        case .searchCurrencyRecommend:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
            
        case .searchMarket(let keyword, let offset, let limit):
            var params: [String: Any] = [:]
            params["limit"] =  String(limit)
            params["offset"] = String(offset)
            params["kw"] = keyword
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .searchSymbol(let keyword, let offset, let limit):
            var params: [String: Any] = [:]
            params["limit"] =  String(limit)
            params["offset"] = String(offset)
            params["kw"] = keyword
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .searchExchangePair(let keyword, let offset, let limit):
            var params: [String: Any] = [:]
            params["limit"] =  String(limit)
            params["offset"] = String(offset)
            params["kw"] = keyword
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
//        default:
//            break
        }
	}
	
	public var headers: [String : String]? {
		return nil
	}
}

struct CurrencyRecommendStruct:Decodable {
	var code:Int
	var msg:String?
	var data:[CurrencySymbolStruct]?
}

struct CurrencySymbolStruct:Decodable {
	var symbol:String?
}


struct SearchMarketStruct:Decodable {
    var code:Int
    var msg:String?
    var data:[SearchMarketContentStruct]?
//    var data:[Dictionary<String, String>]?

}

struct SearchMarketContentStruct:Decodable {
    var type: String? //1:币   其他：交易所
    var symbol: String?
    var icon: String?
    var favorite_status: Int?//1:已收藏 2：未收藏
}
//搜索交易对
struct SearchExchangeStruct:Decodable {
    var code:Int
    var msg:String?
    var data:Dictionary<String, [SearchExchangePairContentStruct]>?
    //    var data:[Dictionary<String, String>]?
}
struct SearchExchangePairContentStruct:Decodable {
    var pair: String?
//    var symbol: String?
    var icon: String?
    var favorite_status: Int?//1:已收藏 2：未收藏
}
