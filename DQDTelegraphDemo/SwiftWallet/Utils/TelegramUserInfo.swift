//
//  TelegramUserInfo.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/28.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit


@objc class TelegramUserInfo: NSObject {
	
	@objc static let shareInstance = TelegramUserInfo.init()
    private override init() {
        super.init()
		
		//set color
        setCurrentLanguageAndGainsColor()
    }
	
    @objc var telegramLoginState: NSString? = "no"//yes or no
    @objc var uid: NSString?
    @objc var phoneNumber: NSString?
	@objc var firstName: NSString?
	@objc var lastName: NSString?
	@objc var userName: NSString?
	@objc var recGroups: NSData?
	var account_id: String?
	var token: String?
    var currentLanguage: String = {
        var languageCode = UserDefaults.standard.object(forKey: BitUpAppLanguageKey)
        if languageCode == nil {
            let language = Locale.preferredLanguages.first
            if (language?.hasPrefix("zh-Hans"))! {
                languageCode = CurrentLanguage.Chinese_Hans.rawValue
            } else if (language?.hasPrefix("zh-Hant"))!  {
                languageCode = CurrentLanguage.Chinese_Hant.rawValue
            } else if (language?.hasPrefix("ja"))!  {
                languageCode = CurrentLanguage.Japanese.rawValue
            } else if (language?.hasPrefix("ko"))!  {
                languageCode = CurrentLanguage.Korean.rawValue
            } else if (language?.hasPrefix("ru"))!  {
                languageCode = CurrentLanguage.Russian.rawValue
            } else {
                languageCode = CurrentLanguage.English.rawValue
            }
        }
        return  languageCode as! String
    }()
//        = {
//       let str =
//    }
    

	typealias GetlinkClosure = (NSString) -> ()
//	@objc var blo:GetlinkClosure?
	@objc func clearUserInfo() {
		TelegramUserInfo.shareInstance.uid = ""
		TelegramUserInfo.shareInstance.phoneNumber = ""
		TelegramUserInfo.shareInstance.firstName = ""
		TelegramUserInfo.shareInstance.lastName = ""
		TelegramUserInfo.shareInstance.userName = ""
		TelegramUserInfo.shareInstance.telegramLoginState = "no"
	}
	typealias RecGroupBlock = (Data) -> ()
	@objc func getFirstRecUrl( block:@escaping GetlinkClosure ,dataBlock:@escaping RecGroupBlock){
		let userD = UserDefaults.standard
		let languages:[String] = userD.object(forKey: "AppleLanguages") as! Array
		let preferredLang = languages.first
		
		var lang:String = "en"
		
		if preferredLang != nil {
			if preferredLang!.hasPrefix("zh-Hans") || preferredLang!.hasPrefix("zh-Hant"){
				lang = "cn"
			}else {
				lang = "en"
			}
		}
		
		LoginAPIProvider.request(LoginAPI.getRecGroups(lang)) {[weak self](result) in
			switch result {
				
			case let .success(response):
				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(RecGroupsStruct.self, from: decryptedData)
				
				
				DispatchQueue.main.async {
					if ((json?.data) != nil){
						let arr:[groupInfoStruct] = (json?.data)!
						if arr.count > 0 {
							
							if let groupInfo = arr.first, let link = groupInfo.link {
								if link.lengthOfBytes(using: String.Encoding.utf8) > 0 {
									block(link as NSString)
								}
							}

							self?.recGroups = decryptedData as NSData
							dataBlock(decryptedData)
						}
					}
				}
				break
			case let .failure(error):
				
				break
			}
		}
	}
	
	//user login
	@objc func requestNetworkLogin( userID:String) {
		LoginAPIProvider.request(LoginAPI.login(userID)) { [weak self](result) in
			switch result {
				
			case let .success(response):
				let decryptedData = Data.init(decryptionResponseData: response.data)
				let json = try? JSONDecoder().decode(LoginStruct.self, from: decryptedData)
				print("login response json: \(String(describing: json))")
                if (json?.code == 10003) {//用户不存在
                    self?.requestNetworkRegister(userID: userID)
                    return
                }
                if (json?.code != 0) { return }
				DispatchQueue.main.async {
					let telegramUserInfo = TelegramUserInfo.shareInstance
					telegramUserInfo.telegramLoginState = "yes"
					let loginInfoStruct:LoginInfoStruct = (json?.data)!
					telegramUserInfo.account_id = loginInfoStruct.accountId
                    UserDefaults.standard.set(loginInfoStruct.accountId, forKey: "TelegramUserInfo.account_id")
					telegramUserInfo.token = loginInfoStruct.token
					print("login state : \(String(describing: telegramUserInfo.telegramLoginState))")
					
					
				}
				break
			case let .failure(error):
				let errorjson = error.localizedDescription
				print("login error json: \(String(describing:errorjson))")
				break
			}
		}
	}
    func requestNetworkRegister( userID:String) {
        LoginAPIProvider.request(LoginAPI.register(userID)) { result in
            switch result {
                
            case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(LoginStruct.self, from: decryptedData)
                print("register ERROR response JSON: \(String(describing: json))")
                
                if (json?.code != 0) { return }
                DispatchQueue.main.async {
                    let telegramUserInfo = TelegramUserInfo.shareInstance
                    telegramUserInfo.telegramLoginState = "yes"
                    let loginInfoStruct:LoginInfoStruct = (json?.data)!
                    telegramUserInfo.account_id = loginInfoStruct.accountId
                    telegramUserInfo.token = loginInfoStruct.token
                    print("login state : \(String(describing: telegramUserInfo.telegramLoginState))")
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Login_Success_Prompt)
                    
                }
                break
            case let .failure(error):
                let errorjson = error.localizedDescription
                print("register error json: \(String(describing:errorjson))")
                break
            }
        }
    }
	//
	//for color
    var settingColorFlag: Bool = {
        let flag = UserDefaults.standard.object(forKey: GainsColorUISwitchStateKey)
        if flag != nil {
//            settingColorFlag = flag! as! Bool
            return flag! as! Bool
        }
       return false
    }()
	 func setCurrentLanguageAndGainsColor() {
		
		let flag = UserDefaults.standard.object(forKey: GainsColorUISwitchStateKey)
		if flag != nil {
			settingColorFlag = flag! as! Bool
			return
		}
		
		let appLanguage = UserDefaults.standard.object(forKey: BitUpAppLanguageKey)
		if appLanguage == nil {
			let language = Locale.preferredLanguages.first
//            var languageCode: String?
            if (language?.hasPrefix("zh-Hans"))! {
//                languageCode = CurrentLanguage.Chinese_Hans.rawValue
                currentLanguage = CurrentLanguage.Chinese_Hans.rawValue
            } else if (language?.hasPrefix("zh-Hant"))!  {
//                languageCode = CurrentLanguage.Chinese_Hant.rawValue
                currentLanguage = CurrentLanguage.Chinese_Hant.rawValue
            } else if (language?.hasPrefix("ja"))!  {
                currentLanguage = CurrentLanguage.Japanese.rawValue

//                languageCode = CurrentLanguage.Japanese.rawValue
            } else if (language?.hasPrefix("ko"))!  {
                currentLanguage = CurrentLanguage.Korean.rawValue

//                languageCode = CurrentLanguage.Korean.rawValue
            } else if (language?.hasPrefix("ru"))!  {
                currentLanguage = CurrentLanguage.Russian.rawValue

//                languageCode = CurrentLanguage.Russian.rawValue
            } else {
                currentLanguage = CurrentLanguage.English.rawValue

//                languageCode = CurrentLanguage.English.rawValue
            }
            print("TelegramUserInfo languageCode = \(String(describing: currentLanguage))")
            
			UserDefaults.standard.set(currentLanguage, forKey: BitUpAppLanguageKey)
			
			if (currentLanguage==CurrentLanguage.Chinese_Hans.rawValue || currentLanguage==CurrentLanguage.Chinese_Hant.rawValue || currentLanguage==CurrentLanguage.Japanese.rawValue){
				
				UserDefaults.standard.set(false, forKey: GainsColorUISwitchStateKey)
				UserDefaults.standard.synchronize()
				settingColorFlag = false
			} else {
				
				UserDefaults.standard.set(true, forKey: GainsColorUISwitchStateKey)
				UserDefaults.standard.synchronize()
				settingColorFlag = true
			}
		}
	}
}
