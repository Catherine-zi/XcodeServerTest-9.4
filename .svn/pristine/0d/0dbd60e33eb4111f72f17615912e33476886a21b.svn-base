//
//  NetworkListener.swift
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/7/26.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import Foundation
import Moya
import Alamofire

let NetworkListenerProvider = MoyaProvider<NetworkListenerAPI>()

public enum NetworkListenerAPI {
	case loadGoogleUrl
}
extension NetworkListenerAPI:TargetType {
	public var headers: [String : String]? {
		return nil
	}
	
	public var baseURL: URL {
		return URL(string: "https://www.google.com")!
	}
	
	public var path: String {
		return "/generate_204"
	}
	
	public var method: Moya.Method {
		return .get
	}
	
	public var sampleData: Data {
		return "{}".data(using: String.Encoding.utf8)!
	}
	
	public var task: Task {
		switch self{
		case .loadGoogleUrl:
			return .requestParameters(parameters: [:], encoding: URLEncoding.default)
		
	 }
	}
	
}

@objc open class NetworkListener:NSObject{
	
	@objc class func isReachable() -> (Bool) {
		
		return NetworkReachabilityManager()?.isReachable ?? false
	}
	
	typealias ChangeBlock = (_ isReachable:Bool) -> ()
	@objc class func monitorNet(block:@escaping ChangeBlock) {//return yes ,need reload
		
		NetworkListenerProvider.request(NetworkListenerAPI.loadGoogleUrl) { (response) in
			print(response)
		}
		let manager = NetworkReachabilityManager()
		
		manager?.startListening()//开始监听网络
		
		manager?.listener = { status in
			if manager?.isReachable ?? false{
				
				switch status{
				case .notReachable:
//					print("the network is not reachable")
					block(false)
				case .unknown:
//					print("It is unknown whether the network is reachable")
					block(true)
				case .reachable(.ethernetOrWiFi):
//					print("通过WiFi链接")
					block(true)
				case .reachable(.wwan):
//					print("通过移动网络链接")
					block(true)
				}
				
			} else {
//				print("网络不可用")
				block(false)

			}
			
		}
		
		
	}
}



