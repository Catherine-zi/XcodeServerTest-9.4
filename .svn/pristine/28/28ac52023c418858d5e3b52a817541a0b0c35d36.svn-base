//
//  SwiftNotificationManager.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/7/25.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit
import KeychainAccess
import EthereumKit

@objc class SwiftNotificationManager:NSObject {
    
    @objc static let shared = SwiftNotificationManager()
    private let notificationCountName = "notificationCountName"
    private let notificationDataName = "notificationDataName"
    private let registrationIdName = "registrationIdName"
    var notificationArray: [NotificationModel] = []
    @objc var notificationCount: Int = 0 {
        didSet {
            UserDefaults.standard.set(notificationCount, forKey: notificationCountName)
        }
    }
    
    private override init() {
        super.init()
        self.notificationCount = UserDefaults.standard.integer(forKey: self.notificationCountName)
        self.requestAllTransactionForNotification()
        self.checkNotificationRegistration()
    }
    
    private func requestAllTransactionForNotification() {
        let group = DispatchGroup()
        for model in SwiftWalletManager.shared.walletArr {
            if let address = model.extendedPublicKey {
                if model.coinType == CoinType.BTC {
                    self.requestBtcData(address: address, group: group)
                } else if model.coinType == CoinType.ETH {
                    if let assets = model.assetsType {
                        for asset in assets {
                            if let _ = asset.contractAddress {
                                self.requestEthData(address: address, asset: asset, group: group)
                            }
                        }
                    }
                }
            }
        }
        group.notify(queue: .main, execute: {
            //                self.loading = false
            self.notificationArray.sort(by: {former, later in
                if let str0 = former.timestamp,
                    let str1 = later.timestamp,
                    let interval0 = TimeInterval(str0),
                    let interval1 = TimeInterval(str1)
                {
                    return interval1.isLess(than: interval0)
                } else {
                    return true
                }
            })
            var arr: [NotificationModel] = []
            if let tempData = UserDefaults.standard.data(forKey: self.notificationDataName),
                let temp = try? JSONDecoder().decode([NotificationModel].self, from: tempData)
            {
                arr = temp
            }
            if let data = try? JSONEncoder().encode(self.notificationArray) {
                UserDefaults.standard.set(data, forKey: self.notificationDataName)
            }
            if self.notificationArray.count > arr.count {
                // new hint
                
            }
            
        })
    }
    
    @objc func checkNotificationRegistration() {
        guard let registrationId = JPUSHService.registrationID() else {
            return
        }
        if registrationId.count == 0 {
            return
        }
        let keychain = Keychain()
        var storedRegId: String?
        if let data = try? keychain.getData(self.registrationIdName),
            let realData = data,
            let arr = try? JSONDecoder().decode([String].self, from: realData)
        {
            if arr.count == 1 {
                storedRegId = arr[0]
                if storedRegId == registrationId {
                    return
                }
            }
        }
        if let data = try? JSONEncoder().encode([registrationId]) {
            try? keychain.set(data, key: self.registrationIdName)
            for wallet in SwiftWalletManager.shared.walletArr {
                if let storedRegId = storedRegId {
                    self.removeNotification(wallet: wallet, registrationId: storedRegId)
                }
                self.addNotification(wallet: wallet)
            }
        }
    }
    
    private func requestBtcData(address: String, group: DispatchGroup) {
        //        self.loading = true
        group.enter()
        BtcAPIProvider.request(BtcAPI.btcTransactionList(address, 0, 999)) { [weak self] (result) in
            //            self?.loading = false
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(BtcTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get transaction list error")
                    group.leave()
                    return
                }
                if let array = json?.data {
                    self?.processTransaction(address: address, asset: nil, array: array)
                }
                group.leave()
            case let .failure(error):
                print("error = \(error)")
            }
        }
    }
    
    private func requestEthData(address: String, asset: AssetsTokensModel, group: DispatchGroup) {
        //        self.loading = true
        group.enter()
        EthAPIProvider.request(EthAPI.ethTransactionList(address, asset.contractAddress!, 1, 999)) { [weak self] (result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(EthTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "request for transaction list error")
                    group.leave()
                    return
                }
                if let array = json?.data {
                    self?.processTransaction(address: address, asset: asset, array: array)
                }
                group.leave()
            case let .failure(error):
                print("request for transaction list error:\n\(error)")
                group.leave()
            }
        }
    }
    
    func processTransaction(address: String, asset:AssetsTokensModel?, array: [Any]) {
        for object in array {
            var notificationModel = NotificationModel()
            if object is BtcTransactionModel {
                // btc
                if let btcModel = object as? BtcTransactionModel {
                    notificationModel.tx_hash = btcModel.txid
                    notificationModel.timestamp = btcModel.blocktime
                    notificationModel.address = address
                    let amount = calculateAmount(address: address, transaction: btcModel)
                    if amount >= 0 {
                        notificationModel.isIn = true
                        notificationModel.value = amount.description + " BTC"
                    } else {
                        notificationModel.isIn = false
                        notificationModel.value = (-1 * amount).description + " BTC"
                    }
                    
                    self.notificationArray.append(notificationModel)
                }
            } else if object is EthTransactionListDataModel {
                // eth
                if let symbol = asset?.symbol,
                    let ethModel = object as? EthTransactionListDataModel
                {
                    notificationModel.tx_hash = ethModel.hash
                    
                    var ether = Decimal()
                    if let valueStr = ethModel.value,
                        let decim = Decimal(string: valueStr)
                    {
                        let powerBase: Decimal = 10
                        ether = decim / pow(powerBase, 18)
                    }
                    notificationModel.value = ether.description + " " + symbol
                    notificationModel.timestamp = ethModel.timestamp
                    notificationModel.address = address
                    if address.lowercased() == ethModel.from?.lowercased() {
                        notificationModel.isIn = false
                    } else {
                        notificationModel.isIn = true
                    }
                    
                    self.notificationArray.append(notificationModel)
                }
            }
        }
    }
    
    private func calculateAmount(address: String, transaction:BtcTransactionModel) -> Decimal {
        var amount = Decimal()
        if transaction.from_address != nil {
            for transfer in transaction.from_address! {
                if transfer.value != nil {
                    if transfer.addr == address {
                        if let decim = Decimal.init(string: transfer.value!) {
                            amount -= decim
                        }
                        break
                    }
                }
            }
        }
        if transaction.to_address != nil {
            for transfer in transaction.to_address! {
                if transfer.value != nil {
                    if transfer.addr == address {
                        if let decim = Decimal.init(string: transfer.value!) {
                            amount += decim
                        }
                        break
                    }
                }
            }
        }
        return amount
    }
    
    @objc func processNewNotification(userInfo: [String: Any]) {
        var notificationModel = NotificationModel()
        
        let content = userInfo["content"] as? String
        if content == "in" || content == "out" {
            notificationModel.isIn = (content == "in" ? true : false)
            if let extras = userInfo["extras"] as? [String: Any] {
                if let address: String = extras["address"] as? String {
                    notificationModel.address = address.lowercased()
                }
                if let value: String = extras["value"] as? String {
                    notificationModel.value = value
                }
                if let timestamp: String = extras["timestamp"] as? String {
                    notificationModel.timestamp = timestamp
                }
            }
        } else {
            notificationModel.address = content?.lowercased()
            if let extras = userInfo["extras"] as? [String: Any] {
                if let from = extras["from_address"] as? String {
                    if notificationModel.address == from.lowercased() {
                        notificationModel.isIn = false
                    } else {
                        notificationModel.isIn = true
                    }
                }
                if let value = extras["value"] as? String,
                    let valueStr = Decimal(string: value)?.description,
                    let symbol = extras["symbol"] as? String
                {
                    notificationModel.value = valueStr + " " + symbol
                } else {
                    notificationModel.value = "0"
                }
                if let timestamp: Int = extras["timestamp"] as? Int {
                    notificationModel.timestamp = timestamp.description
                }
            }
        }
        
        self.notificationArray.insert(notificationModel, at: 0)
        self.notificationCount += 1
        NotificationCenter.post(customeNotification: SWNotificationName.changeNotification)
    }
    
    func addNotification(wallet: SwiftWalletModel) {
        if let address = wallet.extendedPublicKey,
            let registrationId = JPUSHService.registrationID()
        {
            if wallet.coinType == CoinType.BTC {
                BtcAPIProvider.request(BtcAPI.btcAddNoticeTag(registrationId, address)) { (result) in
                    switch result {
                    case let .success(response):
                        let json = try? JSONDecoder().decode(BtcNoticeModel.self, from: response.data)
                        print(json ?? "add notice")
                    case let .failure(error):
                        print("add notice fail: \(error)")
                    }
                }
            } else if wallet.coinType == CoinType.ETH {
                EthAPIProvider.request(EthAPI.ethAddNoticeTag(registrationId, address)) { (result) in
                    switch result {
                    case let .success(response):
                        let json = try? JSONDecoder().decode(BtcNoticeModel.self, from: response.data)
                        print(json ?? "add notice")
                    case let .failure(error):
                        print("add notice fail: \(error)")
                    }
                }
            }
        }
    }
    
    func removeNotification(wallet: SwiftWalletModel, registrationId: String?) {
        if let address = wallet.extendedPublicKey,
            let registrationId = registrationId ?? JPUSHService.registrationID()
        {
            if wallet.coinType == CoinType.BTC {
                BtcAPIProvider.request(BtcAPI.btcRemoveNoticeTag(registrationId, address)) { (result) in
                    switch result {
                    case let .success(response):
                        let json = try? JSONDecoder().decode(BtcNoticeModel.self, from: response.data)
                        print(json ?? "remove notice")
                    case let .failure(error):
                        print("remove notice fail: \(error)")
                    }
                }
            } else if wallet.coinType == CoinType.ETH {
                EthAPIProvider.request(EthAPI.ethRemoveNoticeTag(registrationId, address)) { (result) in
                    switch result {
                    case let .success(response):
                        let json = try? JSONDecoder().decode(BtcNoticeModel.self, from: response.data)
                        print(json ?? "remove notice")
                    case let .failure(error):
                        print("remove notice fail: \(error)")
                    }
                }
            }
        }
    }
    
    struct NotificationModel: Codable {
        var tx_hash: String?
        var address: String?
        var value: String?
        var isIn: Bool?
        var timestamp: String?
    }

}
