//
//  Data+Encryption.swift
//  SwiftWallet
//
//  Created by Selin on 2018/6/4.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation

extension Data {
    init(decryptionResponseData: Data) {
//        assert(decryptionResponseData.count < SP_DynamicKeyLength, "JSON converts to responseObject failed.")
		let responseString: String?  = String.init(data: decryptionResponseData, encoding: String.Encoding.utf8)
		guard let responseStr = responseString else {
			self = Data()
			return
		}
		if responseStr.lengthOfBytes(using: String.Encoding.utf8) < Int(SP_DynamicKeyLength) {
			self = Data()
			return
		}
        let strIndex = responseStr.index(responseStr.startIndex, offsetBy: Int(SP_DynamicKeyLength))
        let dynamicKeySub = responseStr[responseStr.startIndex..<strIndex]
        let decryptKey: String = SPAESEncrypt.generateDecryptKey(fromDynamicKey: String(dynamicKeySub))
        let decryptKeySub2 = responseStr[strIndex..<responseStr.endIndex]
        let decryptedString = SPAESEncrypt.sp_AES128DecryptText(String(decryptKeySub2), withDecryptKey: decryptKey)
//        print("Response JsonString \(String(describing: decryptedString))")
//        assert(decryptedString?.count == 0, "Response decryptedString is nil.")
        self = (decryptedString?.data(using: String.Encoding.utf8))!
    }
    
    init(encryptionParams: Dictionary<String, Any>) {
        let encryptKeys = SPAESEncrypt.generateDynamicKeyDictionary()
        let dynamicKey: String = encryptKeys[SP_AESDynamicKey] as! String
        let encryptKey: String = encryptKeys[SP_AESEncryptKey] as! String
        
        let jsonData = try! JSONSerialization.data(withJSONObject: encryptionParams, options: JSONSerialization.WritingOptions(rawValue: 0))
        let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8)
        let encryptedString: String = SPAESEncrypt.sp_AES128EncryptText(jsonString!, withEncryptKey: encryptKey)!
        let dynamicString = dynamicKey.appending(encryptedString)
        self = dynamicString.data(using: String.Encoding.utf8)!
    }
}
