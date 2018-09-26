//
//  ConstantManager.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import UIKit

public enum CurrentLanguage:String {
    case English = "en"
    case Chinese_Hans = "zh-Hans"
    case Chinese_Hant = "zh-Hant"
    case Japanese = "ja"
    case Korean = "ko"
    case Russian = "ru"
}
let BitUpAppLanguageKey: String = "BitUpAppLanguageKey"

let RefreshAppLanguageNotificationName: String = "RefreshAppLanguageNotificationName"

//国际化
//func SWLocalizedString(key: String, language: String) -> String {
//    let currentLanguage = Bundle.init(path: Bundle.main.path(forResource: language, ofType: "lproj")!)
//    return currentLanguage!.localizedString(forKey: key, value: nil, table: "Localizable")
//}
func SWLocalizedString(key: String) -> String {
    if (UserDefaults.standard.object(forKey: BitUpAppLanguageKey) == nil){
        let language = Locale.preferredLanguages.first
        var languageCode: String?
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
        
        let defaultPath = Bundle.main.path(forResource: languageCode, ofType: "lproj")
       let defaultLanguage = Bundle.init(path: defaultPath!)
        return defaultLanguage!.localizedString(forKey: key, value: nil, table: "Localizable")
    } else {
       let currentLanguage = Bundle.init(path: Bundle.main.path(forResource: UserDefaults.standard.object(forKey: BitUpAppLanguageKey) as? String, ofType: "lproj")!)
        return currentLanguage!.localizedString(forKey: key, value: nil, table: "Localizable")
    }
}


public enum GainsColorType: String {
    case RedUpGreenDown = "RedUpGreenDown"
    case GreenUpRedDown = "GreenUpRedDown"
}
let GainsColorKey: String = "GainsColorKey"
let GainsColorUISwitchStateKey: String = "GainsColorUISwitchStateKey"
let GainsColorSwitchValueChangedNotificationKey: String = "GainsColorSwitchValueChangedNotificationKey"


public var GainsUpColor: UIColor {
	return TelegramUserInfo.shareInstance.settingColorFlag ? UIColor.init(hexColor: "78DA78") : UIColor.init(hexColor: "F96C6C")
}
public var GainsDownColor: UIColor {
	return TelegramUserInfo.shareInstance.settingColorFlag ? UIColor.init(hexColor: "F96C6C") : UIColor.init(hexColor: "78DA78")
}

let APPStore_SWAPPID: String = "1403301364"


//屏幕宏
let SWScreen_bounds:CGRect = UIScreen.main.bounds
let SWScreen_width:CGFloat = UIScreen.main.bounds.width
let SWScreen_height:CGFloat = UIScreen.main.bounds.height
let SWStatusBarH:CGFloat = UIApplication.shared.statusBarFrame.size.height
let SWNavBarHeight:CGFloat = 44


//iPhone X
let SafeAreaTopHeight:CGFloat = SWStatusBarH + SWNavBarHeight
let iPhoneXBottomHeight:CGFloat = 34
let iPhoneXScreenHeight:CGFloat = 812.0

//APP info
struct AppInfo {
    let infoDictionary = Bundle.main.infoDictionary
    let appDisplayName: String = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    let bundleID: String = Bundle.main.bundleIdentifier!
    let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion: String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    let systemName = UIDevice.current.systemName
}
//test userid
//let TestUserId: String = "20039"



//Service Agreement
let ServiceAgreementCN: String = "http://api.web.cryptohubapp.info/h5/policy/services?lang=cn"
let ServiceAgreementEN: String = "http://api.web.cryptohubapp.info/h5/policy/services"

//Privacy agreement
let PrivacyAgreementCN: String = "http://api.web.cryptohubapp.info/h5/policy/privacy?lang=cn"
let PrivacyAgreementEN: String = "http://api.web.cryptohubapp.info/h5/policy/privacy"

