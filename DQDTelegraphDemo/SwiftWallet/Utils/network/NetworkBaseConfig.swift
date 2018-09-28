//
//  NetworkBaseConfig.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/3.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation

public var isTest:Bool = UserDefaults.standard.bool(forKey: "TestAPIKey")
public let websocketUrl = "ws://stream.web.cryptohubapp.info:9501/ws/"

public var SwiftWalletBaseURL: URL {
    if isTest {
        return URL(string: "http://172.31.0.123:8086")!
    }else {
        return URL(string: "http://api.web.cryptohubapp.info")!
    }
}


public var BitcoinBaseURL: URL {
    get {
        if isTest {
            return URL(string: "http://172.31.3.247:3232")!
        }else {
            return URL(string: "http://btcwallet.cryptohubapp.info")!
        }
    }
}

public var EthereumBaseURL: URL {
    get {
        if isTest {
            return URL(string: "http://172.31.3.247:3238")!
        }else {
            return URL(string: "http://ethwallet.cryptohubapp.info")!
        }
    }
}

public var LitecoinBaseURL: URL {
    get {
        if isTest {
            return URL(string: "http://172.31.3.247:3236")!
        }else {
            return URL(string: "http://ltcwallet.cryptohubapp.info")!
        }
    }
}


