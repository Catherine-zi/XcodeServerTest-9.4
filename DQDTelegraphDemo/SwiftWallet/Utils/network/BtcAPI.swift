//
//  EthAPI.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/7.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya

let BtcAPIProvider = MoyaProvider<BtcAPI>()

public enum BtcAPI {
    case btcCurrency(String)
    case btcTransactionList(String, Int, Int)
    case btcUtxos(String)
    case btcSendRawTransaction(String)
    case btcAddNoticeTag(String,String)
    case btcRemoveNoticeTag(String,String)
}

extension BtcAPI:TargetType {
    public var baseURL: URL {
        return BitcoinBaseURL
    }
    
    public var path: String {
        switch self {
        case .btcCurrency(_):
            return "/v1/get_balance"
        case .btcTransactionList(_):
            return "/v1/get_tx_history"
        case .btcUtxos(_):
            return "/v1/get_utxos"
        case .btcSendRawTransaction(_):
            return "/v1/send_raw_transaction"
        case .btcAddNoticeTag(_, _):
            return "/v1/add_notice_tag"
        case .btcRemoveNoticeTag(_, _):
            return "/v1/remove_notice_tag"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
//        var params: [String: Any] = [:]
        switch self {
        case .btcCurrency(let address):
//            params["user_address"] = address
//            let data:Data =  Data.init(encryptionParams: params)
//            return .requestData(data)
            return .requestParameters(parameters: ["user_address": address], encoding: JSONEncoding.default)
        case .btcTransactionList(let address, let start, let end):
            return .requestParameters(parameters: ["user_address": address, "from": start, "to": end], encoding: JSONEncoding.default)
        case .btcUtxos(let address):
            return .requestParameters(parameters: ["user_address": address], encoding: JSONEncoding.default)
        case .btcSendRawTransaction(let rawTx):
            return .requestParameters(parameters: ["rawtx": rawTx], encoding: JSONEncoding.default)
        case .btcAddNoticeTag(let registrationId, let address):
            return .requestParameters(parameters: ["registration_id": registrationId, "user_address": address], encoding: JSONEncoding.default)
        case .btcRemoveNoticeTag(let registrationId, let address):
            return .requestParameters(parameters: ["registration_id": registrationId, "user_address": address], encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

struct BtcBalanceModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:BtcAmountModel
    var page:BtcPageModel
}

struct BtcTransactionListModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:[BtcTransactionModel]
    var page:BtcPageModel
}

struct BtcUtxosModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:[BtcUtxosDataModel]
    var page:BtcPageModel
}

struct BtcRawTransactionModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:BtcRawTransactionDataModel
    var page:BtcPageModel
}

struct BtcNoticeModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:String?
    var page:BtcPageModel
}

struct BtcAmountModel:Codable {
    var unconfirmedTxApperances:String?
    var txApperances:String?
    var totalReceived:String?
    var totalSent:String?
    var addrStr:String?
    var balance:String?
    var unconfirmedBalance:String?
}

struct BtcTransactionModel:Codable {
    var txid:String?
    var valueIn:String?
    var valueOut:String?
    var fees:String?
    var size:String?
    var blockhash:String?
    var blockheight:String?
    var blocktime:String?
    var confirmations:Int?
    var from_address:[BtcTransferModel]?
    var to_address:[BtcTransferModel]?
    var amount:String? = "0.0"
}

struct BtcTransferModel:Codable {
    var value:String?
    var addr:String?
}

struct BtcUtxosDataModel:Codable {
    var address:String?
    var txid:String?
    var vout:Int?
    var scriptPubKey:String?
    var amount:String?
    var shatoshis:Int?
    var height:Int?
    var confirmations:Int?
}

struct BtcRawTransactionDataModel:Codable {
    var txid:String?
}

struct BtcPageModel:Codable {
    var current:String?
}
