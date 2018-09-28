//
//  SwiftExchanger.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/25.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit

@objc class SwiftExchanger:NSObject {
    
    enum SwiftCurrency: String, Codable {
        case Usd = "USD"
        case Cny = "CNY"
        case Btc = "BTC"
        case Eth = "ETH"
        case Krw = "KRW"
        case Eur = "EUR"
        case Jpy = "JPY"
        case Rub = "RUB"
    }
    
    @objc static let shared = SwiftExchanger()
    
    var currency: SwiftCurrency {
        didSet {
            self.setCurrencySymbol()
            if currency == SwiftCurrency.Usd {
                currencyRateToDollar = 1
            } else {
                requestForCurrency(currency: currency.rawValue)
            }
        }
    }
    var currencySymbol: String = "￥"
    var currencyRateToDollar: Decimal = 1
    let currencyStoreKey = "SwiftCurrency"
    let rateStoreKey = "SwiftRate"
    let changeStoreKey = "SwiftChange"
    private var loadingRate = false
    private var rateArray: [String: String] = [:]
    private var change24Array: [String: String] = [:]
    private var blockItems: [DispatchWorkItem] = []
    
	private override init() {
	
        let curData = UserDefaults.standard.string(forKey: currencyStoreKey)
        var currency: SwiftCurrency?
        if curData == nil {
            currency = SwiftCurrency.Usd
            UserDefaults.standard.set(currency!.rawValue, forKey: currencyStoreKey)
        } else {
            currency = SwiftCurrency.init(rawValue: curData!)
        }
        self.currency = currency ?? SwiftCurrency.Usd
	
		super.init()
		
        if self.currency != SwiftCurrency.Usd {
            requestForCurrency(currency: self.currency.rawValue)
        }
        self.setCurrencySymbol()
        
        if let rates = UserDefaults.standard.value(forKey: rateStoreKey) as? [String:String] {
            self.rateArray = rates
        }
        if let changes = UserDefaults.standard.value(forKey: changeStoreKey) as? [String:String] {
            self.change24Array = changes
        }
        
        self.setRate()
        NotificationCenter.default.addObserver(self, selector: #selector(setRate), name: SWNotificationName.reloadAssetsType.notificationName, object: nil)
		
    }
    
    private func setCurrency(newCurrency: SwiftCurrency) {
        currency = newCurrency
        UserDefaults.standard.set(newCurrency.rawValue, forKey: currencyStoreKey)
    }
    
    private func setCurrencySymbol() {
        switch self.currency {
        case .Usd:
            self.currencySymbol = "$"
        case .Cny:
            self.currencySymbol = "￥"
        case .Btc:
            self.currencySymbol = "Ƀ"
        case .Eth:
            self.currencySymbol = "Ξ"
        case .Krw:
            self.currencySymbol = "₩"
        case .Eur:
            self.currencySymbol = "€"
        case .Jpy:
            self.currencySymbol = "JP¥"
        case .Rub:
            self.currencySymbol = "₽"
        }
    }
    
    @objc private func setRate() {
        
        if self.loadingRate {
            return
        }
        self.loadingRate = true
        
        var existTokens: Set = ["BTC", "ETH", "USD", "CNY", "KRW", "EUR", "JPY", "RUB"]
        existTokens.insert(self.currency.rawValue)
        for wallet in SwiftWalletManager.shared.walletArr {
            if wallet.coinType == CoinType.ETH {
                if wallet.assetsType != nil {
                    if wallet.assetsType!.count > 1 {
                        for type in wallet.assetsType! {
                            if type.symbol != nil && type.symbol != "ETH" {
                                existTokens.insert(type.symbol!)
                            }
                        }
                    }
                }
            } else {
                if let type = wallet.coinType?.rawValue {
                    existTokens.insert(type)
                }
            }
        }
        
        let group = DispatchGroup()
        for currency in existTokens {
            self.requestForRate(currency: currency, group: group)
        }
        group.notify(queue: .main, execute: {
            self.loadingRate = false
            if self.rateArray.count > 0 {
                UserDefaults.standard.set(self.rateArray, forKey: self.rateStoreKey)
            }
            if self.change24Array.count > 0 {
                UserDefaults.standard.set(self.change24Array, forKey: self.changeStoreKey)
            }
            NotificationCenter.post(customeNotification: SWNotificationName.getRateSuccess)
        })
    }
    
    private func requestForRate(currency: String, group: DispatchGroup) {
        group.enter()
        if SwiftCurrency.init(rawValue: currency) == nil || currency == "BTC" || currency == "ETH" {
            MarketsAPIProvider.request(MarketsAPI.markets_allDetail(currency)) { [weak self](result) in
                switch result {
                case let .success(response):
                    let decryptedData = Data.init(decryptionResponseData: response.data)
                    let json = try? JSONDecoder().decode(MarketsAllDetailStruct.self, from: decryptedData)
                    if json?.code != 0 {
                        print("get currency rate error:\n\(json?.msg ?? "")")
                        group.leave()
                        return
                    }
                    if let symbol:MarketsAllDetailDataStruct = json!.data {
                        self?.rateArray[currency] = symbol.priceUsd
                        self?.change24Array[currency] = symbol.percentChange24h
                    }
                    group.leave()
                case let .failure(error):
                    print("get currency rate error:\n\(error)")
                    group.leave()
                }
            }
        } else {
            MarketsAPIProvider.request(MarketsAPI.markets_currencyRate(currency)) { [weak self](result) in
                switch result {
                case let .success(response):
                    let decryptedData = Data.init(decryptionResponseData: response.data)
                    let json = try? JSONDecoder().decode(MarketsCurrencyRateModel.self, from: decryptedData)
                    if json?.code != 0 {
                        print("get currency rate error:\n\(json?.msg ?? "")")
                        group.leave()
                        return
                    }
                    if json?.data?.count != nil {
                        if (json?.data?.count)! > 0 {
                            if let rate = json?.data?[0].rate {
                                self?.rateArray[currency] = rate
                            }
                        }
                    }
                    group.leave()
                case let .failure(error):
                    print("get currency rate error:\n\(error)")
                    group.leave()
                }
            }
        }
    }
    
    // setting
    private func requestForCurrency(currency: String) {
        MarketsAPIProvider.request(MarketsAPI.markets_currencyRate(currency)) { [weak self](result) in
            switch result {
            case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsCurrencyRateModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("get currency rate error:\n\(json?.msg ?? "")")
                    return
                }
                if json?.data?.count != nil {
                    if (json?.data?.count)! > 0 {
                        if let rate = json?.data?[0].rate,
                        let decim = Decimal(string: rate) {
                            self?.currencyRateToDollar = decim
                        }
                    }
                }
            case let .failure(error):
                print("get currency rate error:\n\(error)")
            }
        }
    }
    
    func calculateTotalAsset(wallet: SwiftWalletModel) -> String? {
        if self.rateArray.count == 0 {
            self.setRate()
            return nil
        }
        if wallet.allAssets == nil || wallet.assetsType == nil {
            return nil
        }
        var totalBalance = Decimal()
        guard let type = wallet.coinType else {
            return ""
        }
        switch type {
        case .BTC, .LTC:
            if let assets = wallet.allAssets,
            let assetStr = assets[""],
            let decim = Decimal(string: assetStr) {
                let btc = decim
                if self.currency == SwiftCurrency.Btc {
                    totalBalance = btc
                } else {
                    if let btcRate = self.rateArray["BTC"],
                    let decim = Decimal(string: btcRate) {
                        totalBalance = decim * btc / self.currencyRateToDollar
                    } else {
                        totalBalance = Decimal()
                    }
                }
                wallet.assetsType![0].balance = btc
                wallet.assetsType![0].balanceInLegal = totalBalance
            }
        case .ETH:
            for asset in wallet.allAssets! {
                for(index, type) in wallet.assetsType!.enumerated() {
                    if asset.key == type.contractAddress {
                        
                        for data in self.rateArray {
                            var amount = Decimal()
                            if type.symbol == "ETH" {
                                if let wei = Wei.init(asset.value),
                                    let temp = try? Converter.toEther(wei: wei)
                                {
                                    amount = temp
                                }
                            } else {
                                if let temp = Decimal(string: asset.value),
                                    let decim = type.decim,
                                    let decimInt = Int(decim) {
                                    amount = temp / pow(10, decimInt)
                                }
                            }
                            wallet.assetsType![index].balance = amount
                            if data.key == type.symbol {
                                if let value = Decimal(string: data.value),
                                    let wei = Wei.init(asset.value),
                                    let ether = try? Converter.toEther(wei: wei)
                                {
                                    let assetBalance = value * ether / self.currencyRateToDollar
                                    wallet.assetsType![index].balanceInLegal = assetBalance
                                    totalBalance += assetBalance
                                }
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
        wallet.totalAssets = totalBalance
        return totalBalance.description
    }
    
    func calculateTotalCost(wallet: SwiftWalletModel) -> Decimal {
        var cost = Decimal()
        if //let all = wallet.allAssets,
            let assets = wallet.assetsType
        {
            for asset in assets {
                cost += self.calculateSingleCost(asset: asset, all: nil)
            }
        }
        return cost
    }
    
    func calculateSingleCost(asset: AssetsTokensModel, all: [String: String]?) -> Decimal {
        var cost = Decimal()
        if let singleCost = asset.cost,
            let costCurrency = asset.costCurrency
        {
            cost = self.getConvertedCurrency(amount: singleCost, from: costCurrency, to: self.currency)
        }
//        if let contactAddress = asset.contractAddress,
//            let amountStr = all[contactAddress],
//            var amount = Decimal(string: amountStr),
//            var price = asset.costPrice
//        {
//            if asset.costCurrency != self.currency,
//                let costCurrency = asset.costCurrency
//            {
//                price = self.getConvertedCurrency(amount: price, from: costCurrency, to: self.currency)
//            }
//            if let decimStr = asset.symbol == "ETH" ? "18" : asset.decim
//            {
//                let decim = (decimStr as NSString).integerValue
//                var pow = Decimal()
//                var base: Decimal = 1
//                NSDecimalMultiplyByPowerOf10(&pow, &base, Int16(decim), .down)
//                amount = amount / pow
//            }
//            cost = (amount * price)
//        }
        return cost
    }
    
    func calculate24Profit(wallet: SwiftWalletModel) -> Decimal {
        var profit = Decimal()
        if let all = wallet.allAssets,
            let assets = wallet.assetsType
        {
            for asset in assets {
                profit += self.calculateSingleProfit(asset: asset, all: all)
            }
        }
        return profit
    }
    
    func calculateSingleProfit(asset: AssetsTokensModel, all: [String: String]) -> Decimal {
        var profit = Decimal()
        if let contactAddress = asset.contractAddress,
            let symbol = asset.symbol,
            let amountStr = all[contactAddress],
            var amount = Decimal(string: amountStr),
            let rate = self.getRate(symbol: symbol),
            let change = self.getChange24(symbol: symbol)
        {
            if let decimStr = asset.symbol == "ETH" ? "18" : asset.decim
            {
                let decim = (decimStr as NSString).integerValue
                var pow = Decimal()
                var base: Decimal = 1
                NSDecimalMultiplyByPowerOf10(&pow, &base, Int16(decim), .down)
                amount = amount / pow
            }
            profit = amount * rate * (change / 100) / self.currencyRateToDollar
        }
        return profit
    }
    
    @objc func getConvertedCurrencyFromUsd(amountString: String, to targetCurrency: String) -> String? {
        if let decim = Decimal(string: amountString) {
            if let rateStr = self.rateArray[targetCurrency],
                let rate = Decimal(string: rateStr)
            {
				return rate == 0 ? decim.description : (decim / rate).description
            }
        }
        return "0"
    }
    
    func getConvertedCurrency(amount: Decimal, from originCurrency: SwiftCurrency, to targetCurrency: SwiftCurrency) -> Decimal {
        var number = amount
        if let oriRate = self.getRate(symbol: originCurrency.rawValue),
            let tarRate = self.getRate(symbol: targetCurrency.rawValue)
        {
            number = number * oriRate / tarRate
        }
        return number
    }
    
    func getFormattedCurrencyString(amount: Decimal, inDollar: Bool, short: Bool) -> String {
        var convertedAmount = amount
        if inDollar {
            convertedAmount = amount / self.currencyRateToDollar
        }
        var resultValue = convertedAmount
        var formattedStr = "0"
        if short {
            formattedStr = self.getShortedFormattedNumberString(number: convertedAmount)
        } else {
            resultValue = self.getFormattedNumber(number: convertedAmount)
            let formatter = self.getCurrencyFormatter(decimalCount: 20)
            formattedStr = formatter.string(from: resultValue as NSNumber) ?? "0"
        }
        return self.currencySymbol + formattedStr
    }
    
    func getFormattedNumber(number: Decimal) -> Decimal {
        var count = 0
        if number > 100 {
            count = 2
        } else if number > 0.1 {
            count = 4
        } else if number > 0.01 {
            count = 5
        } else {
            count = 8
        }
        var result = Decimal()
        var num = number
        NSDecimalRound(&result, &num, count, .down)
        return result
    }
    
    func getShortedFormattedNumberString(number: Decimal) -> String {
        var symbol = ""
        var amount = number
        if number < 1000 {
        } else if number < 1000000 {
            amount = number / 1000
            symbol = "K"
        } else {
            amount = number / 1000000
            symbol = "M"
        }
        amount = self.getFormattedNumber(number: amount)
        return amount.description + symbol
    }
    
    func convertLegalDecimal(currency: Decimal?) -> String? {
        if currency == nil {
            return nil
        }
        let currencyFormatter = self.getCurrencyFormatter(decimalCount: 2)
        if let priceString = currencyFormatter.string(from: currency! as NSNumber) {
            return priceString
        } else {
            return ""
        }
    }
    
    func getRoundedNumber(number: Decimal, decimalCount: Int) -> Decimal {
        var result = Decimal()
        var num = number
        NSDecimalRound(&result, &num, decimalCount, .down)
        return result
    }
    
    func getRoundedNumberString(numberString: String, decimalCount: Int) -> String {
        let formatter = self.getCurrencyFormatter(decimalCount: decimalCount)
        if let number = Decimal(string: numberString),
            let formattedValue = formatter.string(from: number as NSNumber) {
            return formattedValue
        } else {
            return ""
        }
    }
    
    func getCurrencyFormatter(decimalCount: Int) -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = decimalCount;
        return currencyFormatter
    }
    
    func getRate(symbol: String) -> Decimal? {
        if let rateStr = self.rateArray[symbol],
            let rate = Decimal(string: rateStr)
        {
            return rate
        } else {
            return nil
        }
    }
    
    func getChange24(symbol: String) -> Decimal? {
        if let changeStr = self.change24Array[symbol],
            let change = Decimal(string: changeStr)
        {
            return change
        } else {
            return nil
        }
    }
    
    func getWei(from ether: String) -> Decimal? {
        guard var ether = Decimal(string: ether) else {
            return nil
        }
        var temp = Decimal()
        var wei = Decimal()
        NSDecimalMultiplyByPowerOf10(&temp, &ether, 18, .down)
        NSDecimalRound(&wei, &temp, 0, .down)
        return wei
    }
    
    func getSignumMovedCurrencySymbolString(string: String) -> String {
        var result = string
        if string == "0" {
            result = string
        } else if string.hasPrefix("-") {
            result = "-" + self.currencySymbol + String(string.suffix(string.count - 1))
        } else {
            result = "+" + self.currencySymbol + string
        }
        return result
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
