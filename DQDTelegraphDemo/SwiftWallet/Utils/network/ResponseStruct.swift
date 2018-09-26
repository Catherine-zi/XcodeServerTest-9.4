//
//  ResponseStruct.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/17.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation

struct SimpleStruct: Decodable {
    var code: Int
    var msg: String?
//    var data:
}
//login
struct LoginStruct:Decodable {
    var code: Int
    var msg: String?
    var data: LoginInfoStruct?
}
struct LoginInfoStruct:Decodable {
    var accountId: String?
    var token: String?
    enum CodingKeys : String, CodingKey {
        case accountId = "account_id"
        case token
    }
}
//Markets currencyRecommend
struct MarketsTitleTagsStruct: Decodable {
    var code: Int
    var msg: String?
    var data: Dictionary<String, [String]>?
}

//struct MarketsTitleTagsDataStruct: Decodable {
//    var symbol: String?
//}

//Markets all
struct MarketsAllStruct: Decodable {
    var code: Int
    var msg: String?
    var data: [MarketsAllDataStruct]?
}
//Markets all data
struct MarketsAllDataStruct: Decodable {
    var id: Int?
    var symbol: String?
    var icon: String?
    var marketCapUsd: String?
    var volumeUsd: String?
    var priceUsd: String?
    var percentChange: String?
    var availableSupply: String?
    var totalSupply: String?
    var percentChange24h:String?
    var favoriteStatus: Int

    enum CodingKeys : String, CodingKey {
        case id
        case symbol
        case icon 
        case marketCapUsd = "market_cap_usd"
        case volumeUsd = "volume_usd_24h"
        case priceUsd = "price_usd"
        case percentChange = "percent_change_1h"
        case availableSupply = "available_supply"
        case totalSupply = "total_supply"
        case percentChange24h = "percent_change_24h"
        case favoriteStatus = "favorite_status"
    }
}

//Markets all detail
struct MarketsAllDetailStruct: Decodable {
    var code: Int
    var msg: String?
    var data: MarketsAllDetailDataStruct?
}
struct MarketsAllDetailDataStruct: Decodable {
    var name: String?
    var symbol: String?
    var marketCapUsd: String?
    var volumeUsd: String?
    var priceUsd: String?
    var totalSupply: String?
    var availableSupply: String?
    var percentChange1h: String?
    var percentChange24h: String?
    var openPriceUsd: String?
    var closePriceUsd: String?
    var highPriceUsd: String?
    var lowPriceUsd: String?
    var favoriteStatus: Int?
    var priceBtc: String?
    var volume24hBtc: String?
    var marketCapBtc: String?
    var percentChange1hBtc: String?
    var percentChange24hBtc: String?
    var priceEth: String?
    var volume24hEth: String?
    var marketCapEth: String?
    var percentChange1hEth: String?
    var percentChange24hEth: String?
    var priceHeight52weeks: String?
    var priceLow52weeks: String?
    var priceHeightAll: String?
    var priceLowAll: String?
    var chat: String?

    enum CodingKeys : String, CodingKey {
        case name
        case symbol
        case marketCapUsd = "market_cap_usd"
        case volumeUsd = "volume_usd_24h"
        case priceUsd = "price_usd"
        case totalSupply = "total_supply"
        case availableSupply = "available_supply"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case openPriceUsd = "open_price_usd"
        case closePriceUsd = "close_price_usd"
        case highPriceUsd = "high_price_usd"
        case lowPriceUsd = "low_price_usd"
        case favoriteStatus = "favorite_status"
        case priceBtc = "price_btc"
        case volume24hBtc = "volume_24h_btc"
        case marketCapBtc = "market_cap_btc"
        case percentChange1hBtc = "percent_change_1h_btc"
        case percentChange24hBtc = "percent_change_24h_btc"
        case priceEth = "price_eth"
        case volume24hEth = "volume_24h_eth"
        case marketCapEth = "market_cap_eth"
        case percentChange1hEth = "percent_change_1h_eth"
        case percentChange24hEth = "percent_change_24h_eth"
        case priceHeight52weeks = "price_height_52weeks"
        case priceLow52weeks = "price_low_52weeks"
        case priceHeightAll = "price_height_all"
        case priceLowAll = "price_low_all"
        case chat = "chat"

        
    }
}

//Markets favorites
struct MarketsFavoritesStruct:Decodable {
    var code: Int
    var msg: String?
    var data: [MarketsFavoritesDetailStruct]?
}

struct MarketsFavoritesDetailStruct:Decodable {
    var symbol:String?
    var pair:String?
    var exchange:String?
    var icon : String?
    var priceUSD: String?
    var pairRightPrice:String?
    var percentChange24h:String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case pair
        case exchange
        case icon
        case priceUSD = "price_usd"
        case pairRightPrice = "pair_right_price"
        case percentChange24h = "percent_change_24h"

    }
}
//struct MarketsFavoritesDetailStruct:Decodable {
//    var symbol: String?
//    var icon: String?
//    var priceUsd: String?
//    var percentChange1h: String?
//    var percentChange24h: String?
//    var priceBtc: String?
//    var priceEth: String?
//    var percentChange24hBTC: String?
//    var percentChange24hETH: String?
//
//    enum CodingKeys : String, CodingKey {
//        case symbol
//        case icon
//        case priceUsd = "price_usd"
//        case percentChange1h = "percent_change_1h"
//        case percentChange24h = "percent_change_24h"
//        case priceBtc = "price_btc"
//        case priceEth = "price_eth"
//        case percentChange24hBTC = "percent_change_24h_btc"
//        case percentChange24hETH = "percent_change_24h_eth"
//    }
//}

//Markets exchange
struct MarketsExchangeStruct:Decodable {
    var code: Int
    var msg: String?
    var data: [MarketsExchangeDataStruct]?
}

struct MarketsExchangeDataStruct:Decodable {
    var rank: Int?
    var name: String?
    var volume_usd_24h: String?
}


//Markets ExchangeCurrencys
struct ExchangeCurrencysModel:Codable {
    var msg:String?
    var data:[ExchangeCurrencysDataModel]?
    var code:Int
}

struct ExchangeCurrencysDataModel:Codable {
    var exchangeName:String?
    var pair:String?
    var currencyName:String?
    var icon : String?
    var priceUSD: String?
    var volumeUSD24H:String?
    var volumePercent:String?
    
    enum CodingKeys : String, CodingKey {
        
        case exchangeName = "exchange_name"
        case pair
        case currencyName = "currency_name"
        case icon
        case priceUSD = "price_usd"
        case volumeUSD24H = "volume_usd_24h"
        case volumePercent = "volume_percent_of_exchange"
    }
}

//Markets exchange detail
struct MarketsExchangeDetailStruct:Decodable {
    var code: Int
    var msg: String?
    var data: [MarketsExchangeDetailDataStruct]?
}

struct MarketsExchangeDetailDataStruct:Decodable {
    var exchangeName: String?
    var pair: String?
    var currencyName: String?
    var icon: String?
    var priceUsd: String?
    var volumeUsd24h: String?
    var volumePercentExchange: String?
    
    enum CodingKeys: String, CodingKey {
        case exchangeName = "exchange_name"
        case pair
        case currencyName = "currency_name"
        case icon
        case priceUsd = "price_usd"
        case volumeUsd24h = "volume_usd_24h"
        case volumePercentExchange = "volume_percent_of_exchange"
    }
}

//获取推荐群组
struct RecGroupsStruct:Decodable {
	var code: Int
	var msg: String?
	var data: [groupInfoStruct]?
}

struct groupInfoStruct:Decodable {
	var desc:String?
	var icon:String?
	var link:String?
	var groupName:String?
	
	enum CodingKeys: String, CodingKey {
		case desc = "description"
		case icon
		case groupName = "group_name"
		case link
	}
}

//行情趋势
@objc class MarketTrendStruct:NSObject, Decodable {
	var code: Int?
	var msg: String?
	var data: [CoinStatusStruct]?
}

@objc class CoinStatusStruct:NSObject, Decodable {
	@objc var name:String?
	@objc var volumeusd24h:String?
	@objc var priceUsd:String?
	@objc var availableSupply:String?
	@objc var updatedTime:String?
	@objc var priceBtc:String?
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case volumeusd24h = "volume_usd_24h"
		case priceUsd = "price_usd"
		case availableSupply = "available_supply"
		case updatedTime = "updated_time"
		case priceBtc = "price_btc"
	}
}

//K线图
@objc class MarketKLineStruct:NSObject, Decodable {
	var code: Int?
	var msg: String?
	var data: KLineDataStruct?
}

@objc class KLineDataStruct:NSObject, Decodable {
	var interval:[String]?
	var list: [KLineStruct]?
}

@objc class KLineStruct:NSObject, Decodable {
	@objc var highPrice:String?
	@objc var closePrice:String?
	@objc var lowPrice:String?
	@objc var openPrice:String?
	@objc var volume:String?
	@objc var dateline:String?
	enum CodingKeys: String, CodingKey {
		case highPrice = "high_price"
		case closePrice = "close_price"
		case lowPrice = "low_price"
		case openPrice = "open_price"
		case volume = "volume"
		case dateline = "dateline"
	}
}

//webSocket
struct WebSocketPairStruct:Decodable {
	var priceUsd:Double?
	var price24hChange:String?
	var pairRightPrice:String?
	
	enum CodingKeys: String, CodingKey {
		case priceUsd = "price_usd"
		case price24hChange = "price_change_usd_24h"
		case pairRightPrice = "pair_right_price"
	}
}

//交易对详情页
struct ExchangePairTicketStruct:Decodable {
	var code: Int
	var msg: String?
	var data: PairTicketStruct?
}

struct PairTicketStruct:Decodable {
	var pair:String?
	var exchange:String?
	var priceUsd:String?
	var priceChangeUsd24h:String?
	var openPrice:String?
	var closePrice:String?
	var heightPrice:String?
	var lowPrice:String?
	var pairRightPrice:String?
	var icon:String?
	var symbol:String?
	var volume24h:String?
	
	enum CodingKeys: String, CodingKey {
		case pair = "pair"
		case exchange = "exchange"
		case priceUsd = "price_usd"
		case priceChangeUsd24h = "price_change_usd_24h"
		case openPrice = "open_price"
		case closePrice = "close_price"
		case heightPrice = "high_price"
		case lowPrice = "low_price"
		case pairRightPrice = "pair_right_price"
		case icon = "icon"
		case symbol = "symbol"
		case volume24h = "volume_24h"
	}
}

//提醒List
struct AlertListStruct:Decodable {
	var code: Int
	var msg: String?
	var data: [AlertDetailStruct]?
}
struct AlertDetailStruct:Decodable {
	
	var id:String?
	var exchange:String?
	var above_change:String?
	var above_price:String?
	var below_change:String?
	var below_price:String?
	var icon:String?
	var pair:String?

}
