//
//  EthAPI.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/7.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya

let EthAPIProvider = MoyaProvider<EthAPI>()

public enum EthAPI {
    case ethCurrency(String)
    case ethMutipleBalances(String,[AssetsTokensModel])
    case ethTransactionList(String,String,Int,Int)
    case ethTransactionDetailHash(String)
    case ethTransactionDetailId(String)
    case ethTransactionReceiptHash(String)
    case ethGasPrice()
    case ethGasPriceRange()
    case ethSendRawTransaction(String)
    case ethNonce(String)
    case ethGasInfo()
    case ethAddNoticeTag(String,String)
    case ethRemoveNoticeTag(String,String)
    case ethGetUserHoldToken(String)
}

extension EthAPI:TargetType {
    public var baseURL: URL {
        switch self {
        case .ethGasInfo():
            return URL(string: "http://ethgasstation.info")!
        default:
            return EthereumBaseURL
        }
    }
    
    public var path: String {
        switch self {
        case .ethCurrency(_):
            return "/v1/get_balance"
        case .ethMutipleBalances(_):
            return "/v1/get_multiple_balances"
        case .ethTransactionList(_):
            return "/v1/get_tx_history"
        case .ethTransactionDetailHash(_):
            return "/v1/get_txdetails_by_hash"
        case .ethTransactionDetailId(_):
            return "/v1/get_txdetails_by_id"
        case .ethGasPrice:
            return "/v1/get_gas_price"
        case .ethGasPriceRange:
            return "/v1/get_gas_prize_range"
        case .ethSendRawTransaction(_):
            return "/v1/send_raw_transaction"
        case .ethNonce(_):
            return "/v1/get_tx_count"
        case .ethTransactionReceiptHash(_):
            return "/v1/get_txn_receipt"
        case .ethGasInfo:
            return "/json/ethgasAPI.json"
        case .ethAddNoticeTag(_, _):
            return "/v1/add_notice_tag"
        case .ethRemoveNoticeTag:
            return "/v1/remove_notice_tag"
        case .ethGetUserHoldToken(_):
            return "/v1/get_user_hold_token"
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
        case .ethCurrency(let address):
            return .requestParameters(parameters: ["user_address": address, "contract_address": ""], encoding: JSONEncoding.default)
        case .ethTransactionList(let address, let contractAddress, let page, let per_page):
            return .requestParameters(parameters: ["user_address": address, "contract_address": contractAddress, "page": page, "per_page": per_page], encoding: JSONEncoding.default)
        case .ethTransactionDetailHash(let hash):
            return .requestParameters(parameters: ["tx_hash": hash], encoding: JSONEncoding.default)
        case .ethTransactionDetailId(let id):
            return .requestParameters(parameters: ["tx_id": id], encoding: JSONEncoding.default)
        case .ethGasPrice:
            return .requestPlain
        case .ethGasPriceRange:
            return .requestPlain
        case .ethSendRawTransaction(let rawTx):
            return .requestParameters(parameters: ["signed_transaction": rawTx], encoding: JSONEncoding.default)
        case .ethNonce(let address):
            return .requestParameters(parameters: ["user_address": address], encoding: JSONEncoding.default)
        case .ethTransactionReceiptHash(let hash):
            return .requestParameters(parameters: ["tx_hash": hash], encoding: JSONEncoding.default)
        case .ethMutipleBalances(let address, let contracts):
            var urls:[String] = []
            if contracts.count == 0 {
                urls = [""]
            } else {
                for contract in contracts {
                    urls.append(contract.contractAddress!)
                }
            }
            return .requestParameters(parameters: ["user_address": address, "contract_addresses": urls], encoding: JSONEncoding.default)
        case .ethGasInfo:
            return .requestPlain
        case .ethAddNoticeTag(let registrationId, let address):
            return .requestParameters(parameters: ["registration_id": registrationId, "user_address": address], encoding: JSONEncoding.default)
        case .ethRemoveNoticeTag(let registrationId, let address):
            return .requestParameters(parameters: ["registration_id": registrationId, "user_address": address], encoding: JSONEncoding.default)
        case .ethGetUserHoldToken(let address):
            return .requestParameters(parameters: ["user_address": address], encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

struct EthBalanceModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthAmountModel
    var page:EthPageModel
}

struct EthMultipleBalanceModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:[String:String]
    var page:EthPageModel
}

struct EthTransactionListModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:[EthTransactionListDataModel]
    var page:EthPageModel
}

struct EthTransactionDetailModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthTransactionListDataModel
    var page:EthPageModel
}

struct EthTransactionReceiptModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthTransactionReceiptDataModel
    var page:EthPageModel
}

struct EthGasPriceModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthGasPriceDataModel
    var page:EthPageModel
}

struct EthGasRangeModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthGasRangeDataModel
    var page:EthPageModel
}

struct EthSendTransactionModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthSendTransactionDataModel
    var page:EthPageModel
}

struct EthNonceModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:Int?
    var page:EthPageModel
}

struct EthGasInfoModel:Codable {
    var speed:String?
    var safelow_calc:String?
    var safeLowWait:String?
    var safeLow:String?
    var safelow_txpool:String?
    var fast:String?
    var average_calc:String?
    var average:String?
    var avgWait:String?
    var blockNum:String?
    var fastestWait:String?
    var fastest:String?
    var average_txpool:String?
    var block_time:String?
    var fastWait:String?
}

struct EthHoldingTokenModel:Codable {
    var errcode:Int?
    var msg:String?
    var data:EthHoldingTokenDataModel?
    var page:EthPageModel
}

struct EthHoldingTokenDataModel:Codable {
    var erc20_info:[AssetsTokensModel]?
}

struct EthTransactionListDataModel:Codable {
    var ID:String?
    var CreatedAt:String?
    var updatedAt:String?
    var blockNumber:String?
    var hash:String?
    var nonce:String?
    var blockHash:String?
    var from:String?
    var to:String?
    var value:String?
    var gas:String?
    var gasPrice:String?
    var timestamp:String?
    var transactionIndex:String?
    var isContract:Bool?
    var status:Int?
    var confirmedNum:Int?
    var erc20ContractAddress:String?
    var url:String?
}

struct EthTransactionReceiptDataModel:Codable {
    var transactionHash:String?
    var blockHash:String?
    var blockNumber:String?
    var gasUsed:String?
    var status:String?
    var logs:[EthTransactionReceiptDataLogModel]?
}

struct EthTransactionReceiptDataLogModel:Codable {
    var address:String?
    var blockHash:String?
    var data:String?
    var gasUsed:String?
    var logIndex:String?
    var transactionHash:String?
    var transactionIndex:String?
    var transactionLogIndex:String?
    var type:String?
    var topics:[String]?
}

struct EthGasPriceDataModel:Codable {
    var gasPrice:Int?
}

struct EthGasRangeDataModel:Codable {
    var ID:Int?
    var CreatedAt:String?
    var UpdatedAt:String?
    var DeletedAt:String?
    var min:Int?
    var max:Int?
}

struct EthSendTransactionDataModel:Codable {
    var hash:String?
}

struct EthAmountModel:Codable {
    var amount:String?
}

struct EthPageModel:Codable {
    var current:String?
}
