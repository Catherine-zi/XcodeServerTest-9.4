//
//  SwiftWalletManager.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/7.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import KeychainAccess
import EthereumKit

@objc class SwiftWalletManager:NSObject {
    
	@objc static let shared = SwiftWalletManager()
    static var isTest = UserDefaults.standard.bool(forKey: "TestWalletKey")
    var btcNetwork: BTCNetwork {
        get {
            if SwiftWalletManager.isTest {
                return BTCNetwork.testnet()
            } else {
                return BTCNetwork.mainnet()
            }
        }
    }
	
	private let hdWalletKeyChainName:String = "SwiftWallet_hdWallet_keychainName"
    private let hdWalletKeyChainEncryptName:String = "SwiftWallet_hdWallet_keychainEncryptName"
	private let userSelectedBtcAssetStoreName:String = "SwiftWalletUserSelectedBtcAsset"//for AssetsType Select
	private let userSelectedEthAssetStoreName:String = "SwiftWalletUserSelectedEthAsset"
    private let normalKey = BTCSHA256("bitpub".data(using: .utf8))
	
    var selectedAssetWallet: SwiftWalletModel?
    var walletArr:[SwiftWalletModel] = []
	var btcAssetArr:[String] = []
	var ethAssetArr:[String] = []
	
	//for OC
	@objc var walletCount = 0
	
	private override init() {
		super.init()
		
		let keychain = Keychain()
		let userDefault = UserDefaults.standard
        
        let testData = "//get Assets Page Data".data(using: .utf8)
        let testKey = BTCSHA256("bitpub".data(using: .utf8))
        let encryTestData = NSData.encryptData(testData, key: testKey as! Data, iv: nil)
        let decryTestData = NSData.decryptData(encryTestData as! Data, key: testKey as! Data, iv: nil)
        
        print(String.init(data: decryTestData as! Data, encoding: .utf8))
		
		do {
			
			//get Assets Page Data
			let btcAssetData = userDefault.object(forKey: userSelectedBtcAssetStoreName)
			let ethAssetData = userDefault.object(forKey: userSelectedEthAssetStoreName)
			
			if btcAssetData != nil{
				btcAssetArr = btcAssetData as! [String]
			}else {
				btcAssetArr = ["BTC"]
				userDefault.set(btcAssetArr, forKey: userSelectedBtcAssetStoreName)
				userDefault.synchronize()
			}
			
			if ethAssetData != nil {
				ethAssetArr = ethAssetData as! [String]
			}else {
				ethAssetArr = ["ETH"]
				userDefault.set(ethAssetArr, forKey: userSelectedEthAssetStoreName)
				userDefault.synchronize()
			}
			
			//get wallets  
//            guard let data = try keychain.getData(hdWalletKeyChainName)
            guard let data = try keychain.getData(hdWalletKeyChainEncryptName)
			 else {
				print("data is nil or ")
				return
			}
			
			guard let storeArr = try? JSONDecoder().decode([SwiftWalletModel].self, from: data) else {
				print("cannot decoder arr")
				return
			}
			walletArr = storeArr
			walletCount = walletArr.count
			print("walletManager walletArr")
            
            let holdingGroup = DispatchGroup()
            for wallet in self.walletArr {
                if wallet.coinType == CoinType.ETH
                {
                    self.getHoldingToken(wallet: wallet, group: holdingGroup)
                }
            }
            holdingGroup.notify(queue: .main, execute: {
                NotificationCenter.post(customeNotification: SWNotificationName.reloadAssetsType)
            })
		} catch {
			print("get chainData Failed")
		}
	}
	
	func storeWalletArr() -> Bool{
		
		do {
			
            let keychain = Keychain()
//            let data = try JSONEncoder().encode(walletArr)
//            try keychain.set(data, key: hdWalletKeyChainName)
            let encryptData = try JSONEncoder().encode(walletArr)
            try keychain.set(encryptData, key: hdWalletKeyChainEncryptName)
            walletCount = walletArr.count
			
			NotificationCenter.post(customeNotification: SWNotificationName.addWalletSuccess)
            SPUserEventsManager.shared.trackEventAction(SWUEC_Wallet_Amount, eventPrame: String(walletArr.count))
            
			return true
		} catch {
			print(error)
			return false
		}

	}
    
    func updateHoldingToken(wallet: SwiftWalletModel) {
        let holdingGroup = DispatchGroup()
        self.getHoldingToken(wallet: wallet, group: holdingGroup)
        holdingGroup.notify(queue: .main, execute: {
            NotificationCenter.post(customeNotification: SWNotificationName.reloadAssetsType)
        })
    }
	

	var internalIndex: UInt32 {
		set {
			UserDefaults.standard.set(Int(newValue), forKey: #function)
		}
		get {
			return UInt32(UserDefaults.standard.integer(forKey: #function))
		}
	}
	var externalIndex: UInt32 {
		set {
			UserDefaults.standard.set(Int(newValue), forKey: #function)
		}
		get {
			return UInt32(UserDefaults.standard.integer(forKey: #function))
		}
	}
    
    private func getHoldingToken(wallet: SwiftWalletModel, group: DispatchGroup?) {
        guard let address = wallet.extendedPublicKey else {
            return
        }
        if let group = group {
            group.enter()
        }
        EthAPIProvider.request(EthAPI.ethGetUserHoldToken(address)) { (result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(EthHoldingTokenModel.self, from: response.data)
                if json?.errcode != 0 {
                    print("get user hold token error")
                    if let group = group {
                        group.leave()
                    }
                    return
                }
                if let count = json?.data?.erc20_info?.count,
                    count > 0
                {
                    if let assets = wallet.assetsType,
                        let newAssets = json?.data?.erc20_info
                    {
                        for newAsset in newAssets {
                            var existing = false
                            for asset in assets {
                                if asset.symbol == newAsset.symbol {
                                    existing = true
                                    break
                                }
                            }
                            if !existing {
                                wallet.assetsType?.append(newAsset)
                            }
                        }
                    }
                }
                if let group = group {
                    group.leave()
                }
            case let .failure(error):
                print("get user hold token error: \(error)")
                if let group = group {
                    group.leave()
                }
            }
        }
    }
	
    func normalEncrypt(string: String) -> String? {
        if let normalKey = normalKey,
        let data = string.data(using: .utf8),
        let encryptData = NSData.encryptData(data, key: normalKey as Data, iv: nil) {
            return encryptData.base58String()
        } else {
            return nil
        }
    }
    
    func normalDecrypt(string: String) -> String? {
        if let normalKey = normalKey,
        let data = BTCDataFromBase58(string) as Data?,
        let decryptData = NSData.decryptData(data, key: normalKey as Data, iv: nil) {
            return String.init(data: decryptData as Data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    func customEncrypt(string: String, key: String) -> String? {
        if let keyData = key.data(using: .utf8),
            let customKey = BTCSHA256(keyData),
            let data = string.data(using: .utf8),
            let encryptData = NSData.encryptData(data, key: customKey as Data, iv: nil)
        {
            return encryptData.base58String()
        } else {
            return nil
        }
    }
    
    func customEncrypt(data: Data, key: String) -> Data? {
        if let keyData = key.data(using: .utf8),
            let customKey = BTCSHA256(keyData),
            let encryptData = NSData.encryptData(data, key: customKey as Data, iv: nil)
        {
            return encryptData as Data
        } else {
            return nil
        }
    }
    
    func customDecrypt(string: String, key: String) -> String? {
        if let keyData = key.data(using: .utf8),
            let customKey = BTCSHA256(keyData),
            let data = BTCDataFromBase58(string) as Data?,
            let decryptData = NSData.decryptData(data, key: customKey as Data, iv: nil)
        {
            return String.init(data: decryptData as Data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    func customDecrypt(data: Data, key: String) -> Data? {
        if let keyData = key.data(using: .utf8),
            let customKey = BTCSHA256(keyData),
            let decryptData = NSData.decryptData(data, key: customKey as Data, iv: nil)
        {
            return decryptData as Data
        } else {
            return nil
        }
    }
	
//	func importWallet(seed: Data) {
//		let keychain = Keychain()
//		keychain[data: "swiftWalletSeed"] = seed
//
//	}
	
	//create wallet (store in keychain)
	func createWalletByPrivateKey(privateKey:String,walletName:String,pwd:String,coinType:CoinType) -> (Bool,error:String,Bool,SwiftWalletModel?) {
		
		var publickKey:String = ""
		var assetsTypes:[AssetsTokensModel] = []
		
		//create wallet
        switch coinType {
        case .BTC:
            if SwiftWalletManager.isTest {
                if let thePrivateKey = BTCPrivateKeyAddress(string: privateKey) {
                    if let key = BTCKey.init(privateKeyAddress: thePrivateKey) {
                        print("privateKey = \(key.privateKeyAddress)")
                        publickKey = key.addressTestnet.string
                    } else {
                        return (false,"Invalid private key",false,nil)
                    }
                } else {
                    return (false,"Invalid private key",false,nil)
                }
            } else {
                if let thePrivateKey = BTCPrivateKeyAddress(string: privateKey) {
                    if let key = BTCKey.init(privateKeyAddress: thePrivateKey) {
                        print("privateKey = \(key.privateKeyAddress)")
                        publickKey = key.address.string
                    } else {
                        return (false,"Invalid private key",false,nil)
                    }
                } else {
                    return (false,"Invalid private key",false,nil)
                }
            }
            
            assetsTypes.append(AssetsTokensModel(symbol: "BTC", contractName: "BTC", iconUrl: "BTC_logo", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
            
        case .LTC:
            if SwiftWalletManager.isTest {
                if let thePrivateKey = BTCPrivateKeyAddress(string: privateKey) {
                    if let key = BTCKey.init(privateKeyAddress: thePrivateKey) {
                        publickKey = key.ltcAddressTestnet.string
                    } else {
                        return (false,"Invalid private key",false,nil)
                    }
                } else {
                    return (false,"Invalid private key",false,nil)
                }
            } else {
                if let thePrivateKey = LTCPrivateKeyAddress(string: privateKey) {
                    if let key = BTCKey.init(privateKeyAddress: thePrivateKey) {
                        publickKey = key.ltcAddress.string
                    } else {
                        return (false,"Invalid private key",false,nil)
                    }
                } else {
                    return (false,"Invalid private key",false,nil)
                }
            }
            
            assetsTypes.append(AssetsTokensModel(symbol: "LTC", contractName: "LTC", iconUrl: "LTC_logo", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
            
        case .ETH:
            let wallet: Wallet
            //            do {
            var network:Network?
            if SwiftWalletManager.isTest {
                network = Network.kovan
            } else {
                network = Network.main
            }
            wallet = Wallet(network: network!, privateKey: privateKey, debugPrints: true)
            
            //                privateKey = wallet.dumpPrivateKey()
            publickKey = wallet.generateAddress()
            //                mnemonic = wallet.
            //            }
            
            if wallet.dumpPrivateKey().lengthOfBytes(using: String.Encoding.utf8) == 0 {
                return (false,"Invalid private key",false,nil)
            }
            assetsTypes.append(AssetsTokensModel(symbol: "ETH", contractName: "ETH", iconUrl: "ETH", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
            
        }
		
		//store in keychain
        guard let encryptPrivKey = self.customEncrypt(string: privateKey, key: pwd),
            let encryptPassword = self.normalEncrypt(string: pwd),
            let tempData = privateKey.data(using: .utf8),
            let hash = BTCSHA256(tempData).base58String()
        else {
            return (false,"Invalid private key",false,nil)
        }
        let backgroundColor = CreateRandomColorForWallet.getColorForNewWallet(existWalletCount: SwiftWalletManager.shared.walletArr.count)
		let model = SwiftWalletModel(coinType: coinType,
									 walletName: walletName,
									 password: encryptPassword,
									 extendedPrivateKey: encryptPrivKey,
									 extendedPublicKey: publickKey,
									 walletImage: SwiftWalletHeadImageManager.shared.getImageName(),
									 mnemonic: nil,
									 assetsType: assetsTypes,
                                     hash: hash,
                                     mnemHash: nil,
                                     backgroundColor: backgroundColor,
									 isBackUp: true)
		
		
		let isSuccess = storeWallet(model: model)
		
		return (isSuccess,"",!isSuccess,model)
	}
	
	func createWalletByMnemonic(extendMnemonic:[String]?,walletName:String,pwd:String,coinType:CoinType) -> (Bool,[String],Bool,SwiftWalletModel?) {
		
		var mnemonic:[String] = []
		var privateKey:String = ""
		var publickKey:String = ""
		var assetsTypes:[AssetsTokensModel] = []
        var isBackup = false
		//create wallet
        switch coinType {
        case .BTC:
            var btcMnemonic: BTCMnemonic?
            
            if extendMnemonic != nil {
                mnemonic = extendMnemonic!
                isBackup = true
                btcMnemonic = BTCMnemonic.init(words: mnemonic, password: nil, wordListType: BTCMnemonicWordListType.english)
            } else {
                btcMnemonic = BTCMnemonic(entropy: BTCRandomDataWithLength(16) as Data?, password: nil, wordListType: BTCMnemonicWordListType.english)
                mnemonic = btcMnemonic?.words as! [String]
            }
            
            print(mnemonic)
            
            let blockKeyChain = BTCKeychain.init(seed: btcMnemonic!.seed, network: btcNetwork)
            guard let _ = blockKeyChain?.extendedPrivateKey else {
                
                return (false,[],false,nil)
            }
            guard let _  = blockKeyChain?.extendedPublicKey else {
                
                return (false,[],false,nil)
            }
            
            let derivedKeychain = blockKeyChain?.derivedKeychain(withPath: "m/44'/0'/0'/0/0")
            
            if SwiftWalletManager.isTest {
                privateKey = derivedKeychain!.key.wifTestnet
                publickKey = derivedKeychain!.key.addressTestnet.string
            } else {
                privateKey = derivedKeychain!.key.wif
                publickKey = derivedKeychain!.key.address.string
            }
            
            assetsTypes.append(AssetsTokensModel(symbol: "BTC", contractName: "BTC", iconUrl: "BTC_logo", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
        case .LTC:
            var btcMnemonic: BTCMnemonic?
            
            if extendMnemonic != nil {
                mnemonic = extendMnemonic!
                isBackup = true
                btcMnemonic = BTCMnemonic.init(words: mnemonic, password: nil, wordListType: BTCMnemonicWordListType.english)
            } else {
                btcMnemonic = BTCMnemonic(entropy: BTCRandomDataWithLength(16) as Data?, password: nil, wordListType: BTCMnemonicWordListType.english)
                mnemonic = btcMnemonic?.words as! [String]
            }
            
            print(mnemonic)
            
            let blockKeyChain = BTCKeychain.init(seed: btcMnemonic!.seed, network: btcNetwork)
            guard let _ = blockKeyChain?.extendedPrivateKey else {
                
                return (false,[],false,nil)
            }
            guard let _  = blockKeyChain?.extendedPublicKey else {
                
                return (false,[],false,nil)
            }
            
            let derivedKeychain = blockKeyChain?.derivedKeychain(withPath: "m/44'/2'/0'/0/0")
            
            if SwiftWalletManager.isTest {
                privateKey = derivedKeychain!.key.wifTestnet
                publickKey = derivedKeychain!.key.ltcAddressTestnet.string
            } else {
                privateKey = derivedKeychain!.key.ltcwif
                publickKey = derivedKeychain!.key.ltcAddress.string
            }
            //            let ltcAddress = derivedKeychain!.key.ltcAddress.string
            //            let ltcAddressTestnet = derivedKeychain!.key.ltcAddressTestnet.string
            //            let btcPrivateKey = derivedKeychain!.key.wif
            //            let ltcPrivateKey = derivedKeychain!.key.ltcwif
            
            assetsTypes.append(AssetsTokensModel(symbol: "LTC", contractName: "LTC", iconUrl: "LTC_logo", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
        case .ETH:
            if extendMnemonic != nil {
                mnemonic = extendMnemonic!
                isBackup = true
            } else {
                mnemonic = Mnemonic.create(strength: Mnemonic.Strength.normal, language: WordList.english)
            }
            
            var network:Network?
            if SwiftWalletManager.isTest {
                network = Network.kovan
            } else {
                network = Network.main
            }
            let wallet: Wallet
            do {
                let seed = try Mnemonic.createSeed(mnemonic: mnemonic)
                wallet = try Wallet(seed: seed, network: network!, debugPrints: true)
                
                privateKey = wallet.dumpPrivateKey()
                publickKey = wallet.generateAddress()
                
            } catch let error {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            assetsTypes.append(AssetsTokensModel(symbol: "ETH", contractName: "ETH", iconUrl: "ETH", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
        }
		
        //store in keychainguard
        guard let encryptPrivKey = self.customEncrypt(string: privateKey, key: pwd),
            let encryptPassword = self.normalEncrypt(string: pwd),
            let encodeMnemonic = try? JSONEncoder().encode(mnemonic),
            let encryptMnemonic = self.customEncrypt(data: encodeMnemonic, key: pwd),
            let tempData = privateKey.data(using: .utf8),
            let hash = BTCSHA256(tempData).base58String(),
            let mnemHash = BTCSHA256(encodeMnemonic).base58String()
        else {
            return (false,[],false,nil)
        }
        
        let backgroundColor = CreateRandomColorForWallet.getColorForNewWallet(existWalletCount: SwiftWalletManager.shared.walletArr.count)
		let model = SwiftWalletModel(coinType: coinType,
									 walletName: walletName,
									 password: encryptPassword,
									 extendedPrivateKey: encryptPrivKey,
									 extendedPublicKey: publickKey,
									 walletImage: SwiftWalletHeadImageManager.shared.getImageName(),
									 mnemonic: encryptMnemonic,
									 assetsType: assetsTypes,
                                     hash: hash,
                                     mnemHash: mnemHash,
                                     backgroundColor: backgroundColor,
									 isBackUp: isBackup)
		
		let isSuccess = storeWallet(model: model)
		
		return (isSuccess,mnemonic,!isSuccess,model)
	}
    
    func createWalletByAddress(address:String,walletName:String,coinType:CoinType) -> (Bool,error:String,Bool,SwiftWalletModel?) {
        
        var assetsTypes:[AssetsTokensModel] = []
        
        //create wallet
        switch coinType {
        case .BTC:
            assetsTypes.append(AssetsTokensModel(symbol: "BTC", contractName: "BTC", iconUrl: "BTC_logo", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
        case .LTC:
            assetsTypes.append(AssetsTokensModel(symbol: "LTC", contractName: "LTC", iconUrl: "LTC_logo", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
        case .ETH:
            assetsTypes.append(AssetsTokensModel(symbol: "ETH", contractName: "ETH", iconUrl: "ETH", contractAddress: "", decim: "", saler: "", gas: "", balance:Decimal(), balanceInLegal:Decimal(), costPrice:Decimal(), cost:Decimal(), costCurrency:SwiftExchanger.shared.currency, isSelected:true))
        }
        
        //store in keychain
        let backgroundColor = CreateRandomColorForWallet.getColorForNewWallet(existWalletCount: SwiftWalletManager.shared.walletArr.count)
        let model = SwiftWalletModel(coinType: coinType,
                                     walletName: walletName,
                                     password: nil,
                                     extendedPrivateKey: nil,
                                     extendedPublicKey: address,
                                     walletImage: SwiftWalletHeadImageManager.shared.getImageName(),
                                     mnemonic: nil,
                                     assetsType: assetsTypes,
                                     hash: nil,
                                     mnemHash: nil,
                                     backgroundColor: backgroundColor,
                                     isBackUp: true)
        
        let isSuccess = storeWallet(model: model)
        
        return (isSuccess,"",!isSuccess,model)
    }

	private func storeWallet(model:SwiftWalletModel) -> (Bool) {
		
		SwiftWalletManager.shared.walletArr.append(model)
		let isSuccess = SwiftWalletManager.shared.storeWalletArr()
		
		return isSuccess
	}
    
    func modifyName(privateKeyHash:String, name:String) -> Bool {
        for walletModel in SwiftWalletManager.shared.walletArr {
            if walletModel.extendedPrivateKey == privateKeyHash {
                walletModel.walletName = name
                break
            }
        }
        let isSuccess = SwiftWalletManager.shared.storeWalletArr()
        return isSuccess
    }
    
    func modifyPassword(privateKeyHash:String, password:String) -> Bool {
        var isSuccess = false
        for walletModel in SwiftWalletManager.shared.walletArr {
            if walletModel.extendedPrivateKey == privateKeyHash {
                if let oriPassword = walletModel.password,
                    let oriPwd = self.normalDecrypt(string: oriPassword),
                    let encryptPrivateKey = walletModel.extendedPrivateKey,
                    let privateKey = self.customDecrypt(string: encryptPrivateKey, key: oriPwd),
                    let encryptPrivKey = self.customEncrypt(string: privateKey, key: password)
                {
                    walletModel.extendedPrivateKey = encryptPrivKey
                    walletModel.password = self.normalEncrypt(string: password)
                    isSuccess = SwiftWalletManager.shared.storeWalletArr()
                }
                break
            }
        }
        return isSuccess
    }
    
    func removeWallet(privateKeyHash:String) -> Bool {
        for (index, item) in SwiftWalletManager.shared.walletArr.enumerated() {
            if item.extendedPrivateKey == privateKeyHash {
                SwiftWalletManager.shared.walletArr.remove(at: index)
                break
            }
        }
        let isSuccess = SwiftWalletManager.shared.storeWalletArr()
        return isSuccess
    }
    
    func removeWallet(address:String) -> Bool {
        for (index, item) in SwiftWalletManager.shared.walletArr.enumerated() {
            if item.extendedPublicKey == address,
                item.extendedPrivateKey == nil {
                SwiftWalletManager.shared.walletArr.remove(at: index)
                break
            }
        }
        let isSuccess = SwiftWalletManager.shared.storeWalletArr()
        return isSuccess
    }
    
    func validateEthAddress(address: String) -> Bool {
        if address.hasPrefix("0x") && address.count == 42 {
            let scanner = Scanner(string: address)
            var value: UInt64 = 0
            if scanner.scanHexInt64(&value) {
                if value > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    func validateBtcAddress(address: String) -> Bool {
        let data0 = BTCDataFromBase58Check(address)
        guard let hex = data0?.hex() else {
            return false
        }
        if hex.hasPrefix("6f") || hex.hasPrefix("05") || hex.hasPrefix("c4") || hex.hasPrefix("00") {
            return true
        }
        return false
    }
    
    func validateLtcAddress(address: String) -> Bool {
        let data0 = BTCDataFromBase58Check(address)
        guard let hex = data0?.hex() else {
            return false
        }
        if hex.hasPrefix("6f") || hex.hasPrefix("05") || hex.hasPrefix("c4") || hex.hasPrefix("03") {
            return true
        }
        return false
    }
    
    
    // MARK:converter
    
    func convertData(walletModel: SwiftWalletModel, asset: AssetsTokensModel?, dataArray: [Any]) -> [UniversalTransactionModel]? {
        if dataArray.count == 0 {
            return nil
        }
        
        var uniArray:[UniversalTransactionModel] = []
        
        for object in dataArray {
            var uniModel = UniversalTransactionModel()
            if let type = walletModel.coinType {
                switch type {
                case .BTC, .LTC:
                    let btcModel = object as! BtcTransactionModel
                    uniModel.ID = btcModel.txid
                    let amount = calculateAmount(walletModel: walletModel, transaction: btcModel)
                    if amount >= 0 {
                        uniModel.isIn = true
                        uniModel.amount = amount
                    } else {
                        uniModel.isIn = false
                        uniModel.amount = -1 * amount
                    }
                    if uniModel.isIn! {
                        if btcModel.from_address == nil {
                            uniModel.from = "Newly Generated"
                        } else {
                            for from in btcModel.from_address! {
                                if from.addr != walletModel.extendedPublicKey {
                                    uniModel.from = from.addr
                                    break
                                }
                            }
                        }
                        uniModel.to = walletModel.extendedPublicKey
                    } else {
                        for to in btcModel.to_address! {
                            if to.addr != walletModel.extendedPublicKey {
                                uniModel.to = to.addr
                                break
                            }
                        }
                        uniModel.from = walletModel.extendedPublicKey
                    }
                    uniModel.fee = Decimal(string: btcModel.fees!)?.description
                    uniModel.blockHeight = btcModel.blockheight
                    uniModel.confirmations = btcModel.confirmations
                    uniModel.coinType = type
                    var interval = Date().timeIntervalSince1970
                    if btcModel.blocktime != nil,
                        let temp = TimeInterval(btcModel.blocktime!),
                        temp > 1230739200
                    {
                        interval = temp
                    }
                    let date = Date(timeIntervalSince1970: interval)
                    let dateformatter = DateFormatter()
                    dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
                    dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
                    let dateStr = dateformatter.string(from: date)
                    uniModel.time = dateStr
                    uniModel.timeInterval = interval
                    
                case .ETH:
                    let ethModel = object as! EthTransactionListDataModel
                    uniModel.ID = ethModel.hash
                    uniModel.from = ethModel.from
                    uniModel.to = ethModel.to
                    let amount = try? Converter.toEther(wei: Wei.init(ethModel.value!)!)
                    uniModel.amount = amount
                    let fee = try? Converter.toEther(wei: Wei.init(BInt(ethModel.gas!)! * BInt(ethModel.gasPrice!)!))
                    if ethModel.to == walletModel.extendedPublicKey?.lowercased() {
                        uniModel.isIn = true
                    } else {
                        uniModel.isIn = false
                    }
                    uniModel.fee = fee?.description
                    uniModel.blockHeight = ethModel.blockNumber
                    uniModel.confirmations = ethModel.confirmedNum
                    uniModel.coinType = CoinType.ETH
                    var interval = Date().timeIntervalSince1970
                    if let stamp = ethModel.timestamp,
                        let temp = TimeInterval(stamp),
                        temp > 1230739200
                    {
                        interval = temp
                    }
                    let date = Date(timeIntervalSince1970: interval)
                    let dateformatter = DateFormatter()
                    dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
                    dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
                    let dateStr = dateformatter.string(from: date)
                    uniModel.time = dateStr
                    uniModel.timeInterval = interval
                    uniModel.gasPrice = ethModel.gasPrice
                    uniModel.assetSymbol = asset?.symbol
                    uniModel.assetIconUrl = asset?.iconUrl
                    
                }
            }
            
            if let confirmations = uniModel.confirmations {
                if confirmations < 0 {
                    uniModel.state = 3
                } else if confirmations < 6 {
                    uniModel.state = 2
                } else {
                    uniModel.state = 1
                }
            }
            uniArray.append(uniModel)
        }
        return uniArray
    }
    
    private func calculateAmount(walletModel: SwiftWalletModel, transaction:BtcTransactionModel) -> Decimal {
        var amount = Decimal()
        for transfer in transaction.from_address! {
            if transfer.addr == walletModel.extendedPublicKey {
                amount -= Decimal.init(string: transfer.value!)!
            }
        }
        for transfer in transaction.to_address! {
            if transfer.addr == walletModel.extendedPublicKey {
                amount += Decimal.init(string: transfer.value!)!
            }
        }
        return amount
    }
    
}



extension Notification.Name {
	struct SwiftWalletManager {
		static let walletChanged = Notification.Name("SwiftWalletManager.walletChanged")
	}
}

enum CoinType: String, Codable {
	case BTC = "BTC"
    case LTC = "LTC"
	case ETH = "ETH"
}


class SwiftWalletModel: Codable{
	
	var coinType:CoinType?
	var walletName:String?
	var password:String?
	var extendedPrivateKey:String?
	var extendedPublicKey:String?
	var walletImage:String?
	var mnemonic:Data?
	var assetsType:[AssetsTokensModel]?
	var isBackUp:Bool?
    var allAssets:[String:String]?
    var totalAssets:Decimal?
    var hash:String?
    var mnemHash:String?
    var backgroundColor:String?
    init(coinType:CoinType,walletName:String,password:String?,extendedPrivateKey:String?,extendedPublicKey:String,walletImage:String,mnemonic:Data?,assetsType:[AssetsTokensModel],hash:String?,mnemHash:String?,backgroundColor:String?,isBackUp:Bool)
	{
		self.coinType = coinType
		self.walletName = coinType.rawValue + "_" + walletName
		self.walletImage = walletImage
		self.password = password
		self.extendedPrivateKey = extendedPrivateKey
		self.extendedPublicKey = extendedPublicKey
		self.mnemonic = mnemonic
		self.assetsType = assetsType
		self.isBackUp = isBackUp
        self.hash = hash
        self.mnemHash = mnemHash
        self.backgroundColor = backgroundColor
	}
	
	//序列化
//	func encode(with aCoder: NSCoder) {
//		aCoder.encode(coinType, forKey: "coinType")
//		aCoder.encode(walletName, forKey: "walletName")
//		aCoder.encode(password, forKey: "password")
//		aCoder.encode(extendedPrivateKey, forKey: "extendedPrivateKey")
//		aCoder.encode(walletImage, forKey: "walletImage")
//		aCoder.encode(mnemonic, forKey: "mnemonic")
//	}
//	//反序列化
//	required init?(coder aDecoder: NSCoder) {
//		self.coinType = aDecoder.decodeObject(forKey: "coinType") as? CoinType
//		self.walletName = aDecoder.decodeObject(forKey: "walletName") as? String
//		self.password = aDecoder.decodeObject(forKey: "password") as? String
//		self.extendedPrivateKey = aDecoder.decodeObject(forKey: "extendedPrivateKey") as? String
//		self.walletImage = aDecoder.decodeObject(forKey: "walletImage") as? String
//		self.mnemonic = aDecoder.decodeObject(forKey: "mnemonic") as? [String]
//	}
	
}

