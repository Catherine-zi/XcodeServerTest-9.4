//
//  ChatLoginViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/26.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

@objc public class ChatLoginViewController: UIViewController {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var chatTipLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navTitleLabel.text = SWLocalizedString(key: "chat")
        self.chatTipLabel.text = SWLocalizedString(key: "login_wallet_tips")
        self.loginBtn.setTitle(SWLocalizedString(key: "bitPub_log_in_wallet"), for: .normal)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_LogIn_ChatPage)
    }

	override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClick(_ sender: UIButton) {

		let isAgreeServicePolicy = UserDefaults.standard.bool(forKey: "isAgreeServicePolicy")
		if isAgreeServicePolicy == true {
			
			let confirmVC = TelegramConfirmViewController()
			confirmVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(confirmVC, animated: true)
			SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_LogIn_ChatPage)
		}else {
			
			var urlStr:String
			
			if TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hans.rawValue).rawValue == 0 || TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hant.rawValue).rawValue == 0 {
				urlStr = ServiceAgreementCN
			} else {
				urlStr = ServiceAgreementEN
			}
			let webViewVC:ServicePolicyViewController = ServicePolicyViewController()
			webViewVC.urlStr = urlStr
			webViewVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(webViewVC, animated: true)
		}

    }
    @IBAction func searchButtonClick(_ sender: UIButton) {
        let searchVC:MarketsSearchViewController = MarketsSearchViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    @IBAction func addButtonClick(_ sender: UIButton) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
