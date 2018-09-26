//
//  MarketsAPI.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya


let AlertAPIProvider = MoyaProvider<AlertAPI>()

public enum AlertAPI {
    case alert_set(exchange: String,  //交易所名称
        pair: String,  //交易对
        above_change: String?, //上涨幅度
        above_price: String?, //上涨价格
        below_change: String?,  //下跌幅度
        below_price: String?,  //下跌价格
        id: String?  // 当传输id, 则修改当前记录内容，不传则为新添加
    )
    case alert_set_list(limit: Int, offset: Int)
    case alert_delete(id: Int)
    case alert_msg_history(limit: Int, offset: Int)
    case alert_msg_delete(id: [Int])
}


extension AlertAPI: TargetType {

    public var baseURL: URL {
        return SwiftWalletBaseURL
    }
    
    public var path: String {
        
        switch self {
        case .alert_set(_, _, _, _, _, _, _):
            return "/alert/set"
        case .alert_set_list(_, _):
            return "/alert/setList"
        case .alert_delete(_):
            return "/alert/del"
        case .alert_msg_history(_, _):
            return "/alert/msgHistory"
        case .alert_msg_delete(_):
            return "/alert/msgdel"
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
        params["jpush_reg_id"] = JPUSHService.registrationID()
        
        switch self {
        case .alert_set(let exchange, let pair, let above_change, let above_price, let below_change, let below_price, let id):
            params["exchange"] = exchange
            params["pair"] = pair
            params["above_change"] = above_change
            params["above_price"] = above_price
            params["below_change"] = below_change
            params["below_price"] = below_price
            params["id"] = id
            params["platform"] = 2
            let currentLanguageCode = UserDefaults.standard.string(forKey: BitUpAppLanguageKey)
            var lang = ""
            if currentLanguageCode == CurrentLanguage.Chinese_Hans.rawValue || currentLanguageCode == CurrentLanguage.Chinese_Hant.rawValue {
                lang = "cn"
            } else {
                lang = "en"
            }
            params["lang"] = lang
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .alert_set_list(let limit, let offset):
            params["limit"] = limit
            params["offset"] = offset
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .alert_delete(let id):
            params["id"] = id
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .alert_msg_history(let limit, let offset):
            params["limit"] = limit
            params["offset"] = offset
            params["jpush_reg_id"] = JPUSHService.registrationID()
//            params["jpush_reg_id"] = "13065ffa4e5a2acbcad"

            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .alert_msg_delete(let id):
            params["id"] = id
            params["jpush_reg_id"] = JPUSHService.registrationID()
//            params["jpush_reg_id"] = "13065ffa4e5a2acbcad"

            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        }

    }
    
    public var headers: [String : String]? {
        return nil
    }

}

struct AlertSetDeleteModel: Codable {
    
    var msg:String?
    var data:[String]?
    var code:Int
}

struct AlertSetListModel: Codable {
    
    var msg: String?
    var data: [AlertSetListDataModel]?
    var code: Int
}

struct AlertSetListDataModel: Codable {
    
    var id: String?
    var exchange: String?
    var pair: String?
    var icon: String?
    var above_change: String?
    var above_price: String?
    var below_change: String?
    var below_price: String?
}

struct AlertMsgHistoryModel: Codable {
    
    var msg: String?
    var data: [AlertMsgHistoryDataModel]?
    var code: Int
}

struct AlertMsgHistoryDataModel: Codable {
    
    var id: String?
    var create_time: String?
    var message: String?
}

