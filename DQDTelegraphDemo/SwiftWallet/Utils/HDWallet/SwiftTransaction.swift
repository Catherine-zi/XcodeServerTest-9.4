//
//  SwiftTransaction.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/15.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import KeychainAccess
import EthereumKit

class SwiftTransaction: NSObject {
    
    enum BTCAPI: UInt {
        case Chain
        case Blockchain
        case Testnet
    }
    
    enum BTCFeeRate: UInt, Codable {
        case slow = 2
        case normal = 5
        case fast = 7
    }
    
    enum LTCFeeRate: UInt, Codable {
        case slow = 100
        case normal = 200
        case fast = 500
    }
    
    let defaultGasLimit = 90000
    
    // MARK:BTC

    func createBtcTransaction(privateKey:String, destinationAddress:BTCPublicKeyAddress, changeAddress: BTCPublicKeyAddress, amount: String, feeRate: BTCFeeRate?, api: BTCAPI, completionHandler: @escaping (_ transaction: BTCTransaction?, _ error: Error?) -> (Void)) {
        
        guard let amount = Decimal(string: amount),
            let key = BTCPrivateKeyAddress.init(string: privateKey)?.key
        else {
            completionHandler(nil, nil)
            return
        }
        
        
//        let key0 = BTCKey.init(publicKey: privateKey.data(using: String.Encoding.utf8))
        var getUTXOs: [BTCTransactionOutput]?
        var feeAmount:BTCAmount = 0
        if feeRate == nil {
            feeAmount = BTCAmount(BTCFeeRate.normal.rawValue * 1000)
        } else {
            feeAmount = BTCAmount(feeRate!.rawValue * 1000)
        }
        
        let amountInSantoshi = ((amount * 100000000) as NSNumber).int64Value
        
        switch api {
        case .Blockchain:
            let bci = BTCBlockchainInfo()
            do {
                getUTXOs = try bci.unspentOutputs(withAddresses: [key.compressedPublicKeyAddress]) as? [BTCTransactionOutput]
                let (transaction, error) = self.getBtcTransaction(privateKey: privateKey, destinationAddress: destinationAddress, changeAddress: changeAddress, amount: amountInSantoshi, fee: feeAmount, api: api, getUTXOs: getUTXOs)
                completionHandler(transaction, error)
                return
            }
            catch {
                completionHandler(nil, error)
                return
            }
        case .Chain:
            let chain = BTCChainCom(token: "Free API Token form chain.com")
            do {
                getUTXOs = try chain?.unspentOutputs(with: key.compressedPublicKeyAddress) as? [BTCTransactionOutput]
                let (transaction, error) = self.getBtcTransaction(privateKey: privateKey, destinationAddress: destinationAddress, changeAddress: changeAddress, amount: amountInSantoshi, fee: feeAmount, api: api, getUTXOs: getUTXOs)
                completionHandler(transaction, error)
                return
            }
            catch {
                completionHandler(nil, error)
                return
            }
        case .Testnet:
            var address = ""
            if isTest {
                address = key.addressTestnet.string
            } else {
                address = key.compressedPublicKeyAddress.string
            }
            BtcAPIProvider.request(BtcAPI.btcUtxos(address)) { [weak self](result) in
                switch result {
                case let .success(response):
                    let json = try? JSONDecoder().decode(BtcUtxosModel.self, from: response.data)
                    if json?.errcode != 0 || json?.data == nil {
                        print(json?.msg ?? "get utxos error")
                        completionHandler(nil, nil)
                        return
                    }
                    var outputs: [BTCTransactionOutput] = []
                    for model in (json?.data)! {
                        let out = BTCTransactionOutput()
                        guard let tempAmount = model.amount,
                            let tempDecimal = Decimal(string: tempAmount),
                            let outValue = BTCAmount.init(exactly: (tempDecimal * 100000000) as NSNumber),
                            let tempScript = model.scriptPubKey,
                            let tempIndex = model.vout
                        else {
                            completionHandler(nil, nil)
                            return
                        }
                        out.value = outValue
                        out.script = BTCScript.init(hex: tempScript)
                        out.index = UInt32(tempIndex)
                        out.transactionHash = BTCReversedData(BTCDataFromHex(model.txid))
                        outputs.append(out)
                    }
                    let (transaction, error) = self!.getBtcTransaction(privateKey: privateKey, destinationAddress: destinationAddress, changeAddress: changeAddress, amount: amountInSantoshi, fee: feeAmount, api: api, getUTXOs: outputs)
                    completionHandler(transaction, error)
                    return
                    
                case let .failure(error):
                    print("error = \(error)")
                    completionHandler(nil, error)
                    return
                }
            }
//            for (NSDictionary* item in array) {
//                BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
//
//                txout.value = [item[@"value"] longLongValue];
//                txout.script = [[BTCScript alloc] initWithString:item[@"script"]];
//                txout.index = [item[@"output_index"] intValue];
//                txout.transactionHash = (BTCReversedData(BTCDataFromHex(item[@"transaction_hash"])));
//                [outputs addObject:txout];
//            }
        }
    }
    
    func getBtcTransaction(privateKey:String, destinationAddress:BTCPublicKeyAddress, changeAddress: BTCPublicKeyAddress, amount: BTCAmount, fee: BTCAmount, api: BTCAPI, getUTXOs:[BTCTransactionOutput]?) -> (BTCTransaction?, Error?) {
        
        var errorOut: Error?
        guard let key = BTCPrivateKeyAddress.init(string: privateKey)?.key else {
            return (nil, nil)
        }
//        let key = BTCKey(privateKey: privateKey)
        print("UTXOs for \(key.compressedPublicKeyAddress): \(String(describing: getUTXOs)) \(String(describing: errorOut))")
        
        // Can't download unspent outputs - return with error.
        guard let utxos = getUTXOs?.sorted (by: { $0.value < $1.value }) else {
            return (nil, errorOut)
        }
        
        // Find enough outputs to spend the total amount.
        let totalAmount = amount + fee
        let dustThreshold:BTCAmount = ((Decimal(fee) * 0.148) as NSNumber).int64Value  // min input size = 0.148kb
        
        var getTxouts:[BTCTransactionOutput] = []
        var outAmount:BTCAmount = 0
        
        for txout in utxos {
            if txout.value > dustThreshold {//&& txout.script.isPayToPublicKeyHashScript {
                getTxouts.append(txout)
                outAmount += txout.value
                if outAmount > (totalAmount + dustThreshold) {
                    break
                }
            }
        }
        
        // We support spending just one output for now.
//        guard let txouts = getTxouts else { return (nil, nil) }
        if getTxouts.count == 0 {return (nil, nil)}
        let txouts = getTxouts
        
        // Create a new transaction
        let tx = BTCTransaction()
        
        var spentCoins = BTCAmount(0)
        
        // Add all outputs as inputs
        for txout in txouts {
            let txin = BTCTransactionInput()
            txin.previousHash = txout.transactionHash
            txin.previousIndex = txout.index
            tx.addInput(txin)
            
            print("txhash: http://blockchain.info/rawtx/\(BTCHexFromData(txout.transactionHash))")
            print("txhash: http://blockchain.info/rawtx/\(BTCHexFromData(BTCReversedData(txout.transactionHash))) (reversed)")
            
            spentCoins += txout.value
        }
        
        print(String(format: "Total satoshis to spend:       %lld", spentCoins))
        print(String(format: "Total satoshis to destination: %lld", amount))
        print(String(format: "Total satoshis to fee:         %lld", fee))
        print(String(format: "Total satoshis to change:      %lld", spentCoins - (amount + fee)))
        
        // Add required outputs - payment and change
        let paymentOutput = BTCTransactionOutput(value: amount, address: destinationAddress)
        let changeOutput = BTCTransactionOutput(value: (spentCoins - (amount + fee)), address: changeAddress)
        
        // Idea: deterministically-randomly choose which output goes first to improve privacy.
        tx.addOutput(paymentOutput)
        tx.addOutput(changeOutput)
        
        for i in 0 ..< txouts.count {
            // Normally, we have to find proper keys to sign this txin, but in this
            // example we already know that we use a single private key.
            
            let txout = txouts[i] // output from a previous tx which is referenced by this txin.
            let txin = tx.inputs[i] as! BTCTransactionInput
            
            let sigScript = BTCScript()
            
            let d1 = tx.data
            
            let hashType = BTCSignatureHashType.SIGHASH_ALL
            
            
            let getHash: Data?
            do {
                getHash = try tx.signatureHash(for: txout.script, inputIndex: UInt32(i), hashType: hashType)
            } catch {
                errorOut = error
                getHash = nil
            }
            
            let d2 = tx.data
            

			
			
			print(d1, d2)
            
            // Transaction must not change within signatureHashForScript!
            
            // 134675e153a5df1b8e0e0f0c45db0822f8f681a2eb83a0f3492ea8f220d4d3e4
            guard let hash = getHash else { return (nil, errorOut) }
            print(String(format: "Hash for input %d: \(BTCHexFromData(hash))", i))
            guard let signatureForScript = key.signature(forHash: hash, hashType: hashType),
                let range = Range.init(NSRange(location: 0, length: signatureForScript.count - 1))
            else {
                return (nil, nil)
            }
            let compressedPublicKey = key.compressedPublicKey as Data
            sigScript?.appendData(signatureForScript)
            sigScript?.appendData(compressedPublicKey)
            
            let sig = signatureForScript.subdata(in: range)  // trim hashtype byte to check the signature.
            print(key.isValidSignature(sig, hash: hash))// Signature must be valid
            
            txin.signatureScript = sigScript
        }
        
        // Validate the signatures before returning for extra measure.
        
        do {
            let sm = BTCScriptMachine(transaction: tx, inputIndex: 0)
            let scpt = (txouts.first as BTCTransactionOutput?)?.script.copy() as! BTCScript
            do {
                try sm?.verify(withOutputScript:scpt)
            } catch {
                print("Error: \(error)")
            }
            
        }
        
        // Transaction is signed now, return it.
        
        return (tx, errorOut)
    }
    
    // MARK:LTC
    
    
    func createLtcTransaction(privateKey:String, destinationAddress:LTCPublicKeyAddress, changeAddress: LTCPublicKeyAddress, amount: String, feeRate: LTCFeeRate?, completionHandler: @escaping (_ transaction: BTCTransaction?, _ error: Error?) -> (Void)) {
        
        
        guard let amount = Decimal(string: amount),
            var key = BTCKey() else
        {
            completionHandler(nil, nil)
            return
        }
        if SwiftWalletManager.isTest {
            guard let tempkey = BTCPrivateKeyAddress.init(string: privateKey)?.key else {
                completionHandler(nil, nil)
                return
            }
            key = tempkey
        } else {
            guard let tempkey = LTCPrivateKeyAddress.init(string: privateKey)?.key else {
                completionHandler(nil, nil)
                return
            }
            key = tempkey
        }
//        guard let amount = Decimal(string: amount),
//            let key = LTCPrivateKeyAddress.init(string: privateKey)?.key
//            else {
//                completionHandler(nil, nil)
//                return
//        }
        
        
        //        let key0 = BTCKey.init(publicKey: privateKey.data(using: String.Encoding.utf8))
        var getUTXOs: [BTCTransactionOutput]?
        var feeAmount:BTCAmount = 0
        if feeRate == nil {
            feeAmount = BTCAmount(BTCFeeRate.normal.rawValue * 1000)
        } else {
            feeAmount = BTCAmount(feeRate!.rawValue * 1000)
        }
        
        let amountInSantoshi = ((amount * 100000000) as NSNumber).int64Value
        
        var address = ""
        if isTest {
            address = key.addressTestnet.string
        } else {
            address = key.compressedPublicKeyAddress.string
        }
        LtcAPIProvider.request(LtcAPI.ltcUtxos(address)) { [weak self](result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(ltcUtxosModel.self, from: response.data)
                if json?.errcode != 0 || json?.data == nil {
                    print(json?.msg ?? "get utxos error")
                    completionHandler(nil, nil)
                    return
                }
                var outputs: [BTCTransactionOutput] = []
                for model in (json?.data)! {
                    let out = BTCTransactionOutput()
                    guard let tempAmount = model.amount,
                        let tempDecimal = Decimal(string: tempAmount),
                        let outValue = BTCAmount.init(exactly: (tempDecimal * 100000000) as NSNumber),
                        let tempScript = model.scriptPubKey,
                        let tempIndex = model.vout
                        else {
                            completionHandler(nil, nil)
                            return
                    }
                    out.value = outValue
                    out.script = BTCScript.init(hex: tempScript)
                    out.index = UInt32(tempIndex)
                    out.transactionHash = BTCReversedData(BTCDataFromHex(model.txid))
                    outputs.append(out)
                }
                let (transaction, error) = self!.getLtcTransaction(privateKey: privateKey, destinationAddress: destinationAddress, changeAddress: changeAddress, amount: amountInSantoshi, fee: feeAmount, getUTXOs: outputs)
                completionHandler(transaction, error)
                return
                
            case let .failure(error):
                print("error = \(error)")
                completionHandler(nil, error)
                return
            }
        }
    }
    
    func getLtcTransaction(privateKey:String, destinationAddress:LTCPublicKeyAddress, changeAddress: LTCPublicKeyAddress, amount: BTCAmount, fee: BTCAmount, getUTXOs:[BTCTransactionOutput]?) -> (BTCTransaction?, Error?) {
        
        var errorOut: Error?
        guard var key = BTCKey() else {
            return (nil, nil)
        }
        if SwiftWalletManager.isTest {
            guard let tempkey = BTCPrivateKeyAddress.init(string: privateKey)?.key else {
                return (nil, nil)
            }
            key = tempkey
        } else {
            guard let tempkey = LTCPrivateKeyAddress.init(string: privateKey)?.key else {
                return (nil, nil)
            }
            key = tempkey
        }
        //        let key = BTCKey(privateKey: privateKey)
        print("UTXOs for \(key.compressedPublicKeyAddress): \(String(describing: getUTXOs)) \(String(describing: errorOut))")
        
        // Can't download unspent outputs - return with error.
        guard let utxos = getUTXOs?.sorted (by: { $0.value < $1.value }) else {
            return (nil, errorOut)
        }
        
        // Find enough outputs to spend the total amount.
        let totalAmount = amount + fee
        let dustThreshold:BTCAmount = ((Decimal(fee) * 0.148) as NSNumber).int64Value  // min input size = 0.148kb
        
        var getTxouts:[BTCTransactionOutput] = []
        var outAmount:BTCAmount = 0
        
        for txout in utxos {
            if txout.value > dustThreshold {//&& txout.script.isPayToPublicKeyHashScript {
                getTxouts.append(txout)
                outAmount += txout.value
                if outAmount > (totalAmount + dustThreshold) {
                    break
                }
            }
        }
        
        // We support spending just one output for now.
        //        guard let txouts = getTxouts else { return (nil, nil) }
        if getTxouts.count == 0 {return (nil, nil)}
        let txouts = getTxouts
        
        // Create a new transaction
        let tx = BTCTransaction()
        
        var spentCoins = BTCAmount(0)
        
        // Add all outputs as inputs
        for txout in txouts {
            let txin = BTCTransactionInput()
            txin.previousHash = txout.transactionHash
            txin.previousIndex = txout.index
            tx.addInput(txin)
            
            print("txhash: http://blockchain.info/rawtx/\(BTCHexFromData(txout.transactionHash))")
            print("txhash: http://blockchain.info/rawtx/\(BTCHexFromData(BTCReversedData(txout.transactionHash))) (reversed)")
            
            spentCoins += txout.value
        }
        
        print(String(format: "Total satoshis to spend:       %lld", spentCoins))
        print(String(format: "Total satoshis to destination: %lld", amount))
        print(String(format: "Total satoshis to fee:         %lld", fee))
        print(String(format: "Total satoshis to change:      %lld", spentCoins - (amount + fee)))
        
        // Add required outputs - payment and change
        let paymentOutput = BTCTransactionOutput(value: amount, address: destinationAddress)
        let changeOutput = BTCTransactionOutput(value: (spentCoins - (amount + fee)), address: changeAddress)
        
        // Idea: deterministically-randomly choose which output goes first to improve privacy.
        tx.addOutput(paymentOutput)
        tx.addOutput(changeOutput)
        
        for i in 0 ..< txouts.count {
            // Normally, we have to find proper keys to sign this txin, but in this
            // example we already know that we use a single private key.
            
            let txout = txouts[i] // output from a previous tx which is referenced by this txin.
            let txin = tx.inputs[i] as! BTCTransactionInput
            
            let sigScript = BTCScript()
            
            let d1 = tx.data
            
            let hashType = BTCSignatureHashType.SIGHASH_ALL
            
            
            let getHash: Data?
            do {
                getHash = try tx.signatureHash(for: txout.script, inputIndex: UInt32(i), hashType: hashType)
            } catch {
                errorOut = error
                getHash = nil
            }
            
            let d2 = tx.data
            
            
            
            
            print(d1, d2)
            
            // Transaction must not change within signatureHashForScript!
            
            // 134675e153a5df1b8e0e0f0c45db0822f8f681a2eb83a0f3492ea8f220d4d3e4
            guard let hash = getHash else { return (nil, errorOut) }
            print(String(format: "Hash for input %d: \(BTCHexFromData(hash))", i))
            guard let signatureForScript = key.signature(forHash: hash, hashType: hashType),
                let range = Range.init(NSRange(location: 0, length: signatureForScript.count - 1))
                else {
                    return (nil, nil)
            }
            let compressedPublicKey = key.compressedPublicKey as Data
            sigScript?.appendData(signatureForScript)
            sigScript?.appendData(compressedPublicKey)
            
            let sig = signatureForScript.subdata(in: range)  // trim hashtype byte to check the signature.
            print(key.isValidSignature(sig, hash: hash))// Signature must be valid
            
            txin.signatureScript = sigScript
        }
        
        // Validate the signatures before returning for extra measure.
        
        do {
            let sm = BTCScriptMachine(transaction: tx, inputIndex: 0)
            let scpt = (txouts.first as BTCTransactionOutput?)?.script.copy() as! BTCScript
            do {
                try sm?.verify(withOutputScript:scpt)
            } catch {
                print("Error: \(error)")
            }
            
        }
        
        // Transaction is signed now, return it.
        
        return (tx, errorOut)
    }
    
    // MARK:Eth
    
    // ================= eth =====================
    
    func createEthTransaction(privateKey:String, destinationAddress:String, assetModel:AssetsTokensModel, ether: Decimal, gasPrice: Int, gasLimit: Int?, data:Data?, completionHandler: @escaping (_ tx:String?, _ error:Error?)->(Void)) {
        
        var network:Network?
        if SwiftWalletManager.isTest {
            network = Network.kovan
        } else {
            network = Network.main
        }
        let wallet = Wallet(network: network!, privateKey: privateKey, debugPrints: true)
        EthAPIProvider.request(EthAPI.ethNonce(wallet.generateAddress())) { [weak self](result) in
            switch result {
            case let .success(response):
                //                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(EthNonceModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get nonce error")
                    completionHandler(nil, nil)
                    return
                }
                let nonce = json?.data ?? 0
                let (tx, error) = self!.getEthTransaction(privateKey: privateKey, destinationAddress: destinationAddress, assetModel: assetModel, ether: ether, gasPrice: gasPrice, gasLimit: gasLimit ?? self!.defaultGasLimit, nonce: nonce, data:data)
                completionHandler(tx, error)
                
            case let .failure(error):
                completionHandler(nil, error)
            }
        }
    }
    
    
    
    func getEthTransaction(privateKey:String, destinationAddress:String, assetModel:AssetsTokensModel, ether: Decimal, gasPrice: Int, gasLimit: Int, nonce:Int, data:Data?) -> (String?,Error?) {
        
        var network:Network?
        if SwiftWalletManager.isTest {
            network = Network.kovan
        } else {
            network = Network.main
        }
        let wallet = Wallet(network: network!, privateKey: privateKey, debugPrints: true)
        guard let temp = SwiftExchanger.shared.getWei(from: ether.description),
            let wei = Wei.init(temp.description)
        else {
            let userInfo: [String: Any] =
                [NSLocalizedDescriptionKey: "Amount error",
                 NSLocalizedFailureReasonErrorKey: "Error when converting to wei"]
            let err = NSError(domain: "EthTransactionDomain", code: 101, userInfo: userInfo)
            return (nil, err)
        }
        
        var rawTransaction: RawTransaction
        guard let symbol = assetModel.symbol else {
            let userInfo: [String: Any] =
                [NSLocalizedDescriptionKey: "Asset model error",
                NSLocalizedFailureReasonErrorKey: "No symbol in asset"]
            let err = NSError(domain: "EthTransactionDomain", code: 101, userInfo: userInfo)
            return (nil, err)
        }
        
        if symbol == "ETH" {
            if data == nil {
                rawTransaction = RawTransaction.init(
                    value: wei,
                    to: destinationAddress,
                    gasPrice: gasPrice,
                    gasLimit: gasLimit,
                    nonce: nonce)
            } else {
                rawTransaction = RawTransaction.init(
                    wei: wei.description,
                    to: destinationAddress,
                    gasPrice: gasPrice,
                    gasLimit: gasLimit,
                    nonce: nonce,
                    data: data!)
            }
        } else {
            guard let contractAddress = assetModel.contractAddress,
            let decim = assetModel.decim,
            let decimal = Int(decim)
            else {
                let userInfo: [String: Any] =
                    [NSLocalizedDescriptionKey: "Asset model error",
                     NSLocalizedFailureReasonErrorKey: "No contractAddress or decimal in asset"]
                let err = NSError(domain: "EthTransactionDomain", code: 102, userInfo: userInfo)
                return (nil, err)
            }
            let erc20Token = ERC20(contractAddress: contractAddress, decimal: decimal, symbol: symbol)
            var parameterData: Data
            do {
                parameterData = try erc20Token.generateDataParameter(toAddress: destinationAddress, amount: ether.description)
            } catch let error {
                return (nil, error)
            }
            rawTransaction = RawTransaction(
                wei: "0",
                to: erc20Token.contractAddress,
                gasPrice: gasPrice,
                gasLimit: gasLimit,
                nonce: nonce,
                data: parameterData
            )
        }
        var tx: String?
        do {
            tx = try wallet.sign(rawTransaction: rawTransaction)
        } catch let error {
            return (nil, error)
        }
        return (tx, nil)
    }
    
}


struct UniversalTransactionModel:Codable {
    var isIn: Bool?
    var state: Int?
    var amount: Decimal?
    var ID: String?
    var time: String?
    var timeInterval: TimeInterval?
    var from: String?
    var to: String?
    var fee: String?
    var gasPrice: String?
    var blockHeight: String?
    var confirmations: Int?
    var coinType: CoinType?
    var assetIconUrl: String?
    var assetSymbol: String?
}
