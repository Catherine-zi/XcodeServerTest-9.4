//
//  LoginAPI.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import Moya

//let MarketsAPIProvider = MoyaProvider<MarketsAPI>()
let LoginAPIProvider = MoyaProvider<LoginAPI>()

public enum LoginAPI {
    case login(String)
    case register(String)
    case feedback(String, String)
	case getRecGroups(String)
}

extension LoginAPI:TargetType {
    public var baseURL: URL {
        return SwiftWalletBaseURL
    }
    
    public var path: String {
        switch self {
        case .login(_):
            return "/passport/login"
        case .register(_):
            return "/passport/register"
        case .feedback(_, _):
            return "/account/feedback"
		case .getRecGroups(_):
			return "/group/recommendgroup"
		}
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        var params:[String: Any] = [:]
        switch self {
        case .login(let account):
            params["device_id"] = AppInfo.init().uuid
            params["account"] = account
            params["password"] = "596049560"
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .register(let account):
            params["account"] = account
            params["password"] = "596049560"
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .feedback(let email, let content):
            params["email"] = email
            params["content"] = content
            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
            
		case .getRecGroups(let language):
			params["lang"] = language
			let data:Data =  Data.init(encryptionParams: params)
			return .requestData(data)
		}
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

