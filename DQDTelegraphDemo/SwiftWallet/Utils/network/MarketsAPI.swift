//
//  MarketsAPI.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya


let MarketsAPIProvider = MoyaProvider<MarketsAPI>()

public enum MarketsAPI {
    case markets_pairsTags
    case markets_exchangeTags
    case markets_currencyRecommend
    case markets_favorites(Int, Int)
    case markets_setDefaultCurrencyFavorite
    case markets_currencyFavorite(String, String,String,Bool)
    case markets_exchanges(Int, Int)
    case markets_exchangePairs(String, String, Int, Int)
    case markets_exchangeCurrencys(Int, Int, String)
    case markets_exchangesDetail(Int, Int, String)
    case markets_all(String, Int, Int)
    case markets_allDetail(String)
	case markets_trend(String,String,String,String)
    case markets_currencyRate(String)
	case markets_kLine(String,String,String,String,String)
    case markets_pairTag
    case markets_exchangeTag
    case markets_coinPair(String,Int,Int,String)
	case markets_exchangePairTicket(String,String)
}


extension MarketsAPI: TargetType {

    public var baseURL: URL {
        return SwiftWalletBaseURL
    }
    
    public var path: String {
        
        switch self {
        case .markets_pairsTags:
            return "/index/pairTags"

        case .markets_exchangeTags:
            return "/index/exchangeTags"
            
        case .markets_currencyRecommend:
            return "/search/currencyRecommend"

        case .markets_setDefaultCurrencyFavorite:
            return "/account/setDefaultCurrencyFavorite"

        case .markets_favorites(_):
//            return "/account/favorites"
            return "/v2/account/favorites"
            
        case .markets_currencyFavorite(_, _, _, let isFavorites):
            let pathStr = isFavorites == true ? "/account/currencyFavorite" : "/account/currencyCancelFavorite"
            return pathStr
            
        case .markets_all(_):
            return "/market/tickers"
            
        case .markets_allDetail(_):
            return "/market/detail"
            
        case .markets_exchanges(_):
            return "/market/exchanges"
            
        case .markets_exchangePairs(_):
            return "/exchange/pairs"
            
        case .markets_exchangeCurrencys(_):
            return "/market/exchangeCurrencys"
            
        case .markets_exchangesDetail(_, _, _):
            return "/market/exchangeCurrencys"
		case .markets_trend(_):
			return "/market/trend"
        case .markets_currencyRate(_):
            return "/currency/rate"
			
		case .markets_kLine(_,_,_,_,_):
			return "/kline"
	
        case .markets_pairTag:
            return "/index/pairTags"
        case .markets_exchangeTag:
            return "/index/exchangeTags"
        case .markets_coinPair(_, _, _, _):
            return "/symbol/pairs"
		case .markets_exchangePairTicket(_, _):
			return "/v2/exchange/pairTicket"
		}
		

    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        
        switch self {
        case .markets_pairsTags:
            let data:Data =  Data.init(encryptionParams: [:])
            return .requestData(data)
            
        case .markets_exchangeTags:
            let data:Data =  Data.init(encryptionParams: [:])
            return .requestData(data)
            
        case .markets_currencyRecommend:
            let data:Data =  Data.init(encryptionParams: [:])
            return .requestData(data)

        case .markets_setDefaultCurrencyFavorite:
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_favorites(let offset, let limit):
            //APP启动时，由于登录接口先走tg登录再走我司登录接口 有延时，故用此方法取用户id
            let telegraphUserActivated = UserDefaults.standard.value(forKey: "telegraphUserActivated")
            let account_id = UserDefaults.standard.object(forKey: "TelegramUserInfo.account_id")
            if telegraphUserActivated != nil, telegraphUserActivated as! Bool == true {
                if telegraphUserActivated != nil,account_id != nil {
                    params["account_id"] = account_id
                }
            }
           
//            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
//                params["account_id"] = TelegramUserInfo.shareInstance.account_id
//            }
            params["device_id"] = AppInfo.init().uuid
            params["limit"] =  String(limit)
            params["offset"] = String(offset)
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_currencyFavorite(let symbol, let exchange,let pair, _):
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            if symbol.count != 0 {
                params["symbol"] = symbol
            }
            if exchange.count != 0 && pair.count != 0 {
                params["exchange"] = exchange
                params["pair"] = pair
            }
            let data:Data = Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_all(let sort, let offset, let limit):
            params["limit"] =  String(limit)
            params["offset"] = String(offset)
            params["sort"] = sort
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        
        case .markets_allDetail(let symbol):
            params["symbol"] = symbol
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_exchanges(let offset, let limit):
            params["limit"] = String(limit)
            params["offset"] = String(offset)
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_exchangePairs(let exchangeName,let sortKey,let offset,let limit):
            params["exchange"] = exchangeName
            params["sort"] = sortKey
            params["offset"] = String(offset)
            params["limit"] = String(limit)
            params["device_id"] = AppInfo.init().uuid
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_exchangeCurrencys(let offset, let limit, let exchangeName):
            params["limit"] = String(limit)
            params["offset"] = String(offset)
            params["name"] = exchangeName
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
        case .markets_exchangesDetail(let offset, let limit, let exchangeName):
            params["limit"] = String(limit)
            params["offset"] = String(offset)
            params["name"] = exchangeName
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)

		case .markets_trend(let symbol,let begin,let end,let typeStr):
			params["symbol"] = String(symbol)
			params["begin"] = String(begin)
			params["end"] = String(end)
			params["type"] = String(typeStr)
			let data:Data =  Data.init(encryptionParams: params)
			return .requestData(data)
		
        case .markets_currencyRate(let name):
            params["currency"] = name
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
		case .markets_kLine(let exchange,let symbol,let limit,let interval,let endTime):
			params["exchange"] = String(exchange)
			params["symbol"] = String(symbol)
			params["limit"] = String(limit)
			params["interval"] = String(interval)
			params["end_time"] = String(endTime)
			let data:Data =  Data.init(encryptionParams: params)
			return .requestData(data)
        case .markets_pairTag:
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .markets_exchangeTag:
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .markets_coinPair(let symbol,let offset,let limit,let sort):
            params["symbol"] = symbol
            params["limit"] = String(limit)
            params["offset"] = String(offset)
            params["sort"] = sort
            if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
                params["account_id"] = TelegramUserInfo.shareInstance.account_id
            }
            params["device_id"] = AppInfo.init().uuid
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
		case .markets_exchangePairTicket(let exchange, let pair):
			
			params["exchange"] = String(exchange)
			params["pair"] = String(pair)
			let data:Data =  Data.init(encryptionParams: params)
			return .requestData(data)
		}

    }
    
    public var headers: [String : String]? {
        return nil
    }

}

struct MarketsCurrencyRateModel:Codable {
    
    var msg:String?
    var data:[MarketsCurrencyRateDataModel]?
    var code:Int
}

struct MarketsCurrencyRateDataModel:Codable {
    
    var id:String?
    var currency:String?
    var rate:String?
}

struct MarketsPairTagModel:Codable {
    
    var msg:String?
    var data:MarketsPairTagDataModel?
    var code:Int
}

struct MarketsExchangeTagModel:Codable {
    
    var msg:String?
    var data:[String]?
    var code:Int
}

struct MarketsCoinPairModel:Codable {
    
    var msg:String?
    var data:[MarketsCoinPairDataModel]?
    var code:Int
}

struct MarketsPairTagDataModel:Codable {
    var pair:[String]?
    var more_tags:[String]?
}

struct MarketsCoinPairDataModel:Codable {
    var symbol:String?
    var pair:String?
    var exchange:String?
    var price_usd:String?
    var price_change_usd_24h:String?
    var volume_24h:String?
    var pair_right_price:String?
    var icon:String?
    var favorite_status:Int?
}

//var exchangeName:String?
//var pair:String?
//var currencyName:String?
//var icon : String?
//var priceUSD: String?
//var volumeUSD24H:String?
//var volumePercent:String?

