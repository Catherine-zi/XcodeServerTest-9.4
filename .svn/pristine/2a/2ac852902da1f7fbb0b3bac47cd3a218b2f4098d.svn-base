//
//  TelegramConfirmViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/5/3.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

@objc public class TelegramConfirmViewController: UIViewController {
   

    @IBOutlet weak var infoTipsLabel: UILabel!
    @IBOutlet weak var navTitltLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    var phoneNumber: NSString?
	@objc var recGroupURL: NSString?
	override public func viewDidLoad() {
        super.viewDidLoad()
        self.navTitltLabel.text = SWLocalizedString(key: "my_account")
        self.tipsLabel.text = SWLocalizedString(key: "my_login_tips1")
        self.cancelButton.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_confirm"), for: .normal)
        // Do any additional setup after loading the view.
		self.infoTipsLabel.text = SWLocalizedString(key: "my_login_tips2")
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_CommonAccount_Page)
    }

	override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backButtonClick(_ sender: Any) {
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_CommonAccount_Page)
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func confirmButtonClick(_ sender: Any) {
//        self.requestNetworkData()
		SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_CommonAccount_Page)
		let chatInTabBarCount:Int = 1
		if self.tabBarController?.selectedIndex == chatInTabBarCount {
			//go to loginC
			let vc = SWTabBarController.loginNavigationController()
			self.present(vc!, animated: true, completion: nil)
		}else {
			
			self.tabBarController?.selectedIndex = chatInTabBarCount
			
			guard let tabVc:UITabBarController = self.tabBarController else{
				return
			}
			if tabVc.viewControllers?.count == 4 {
				let vc:UIViewController = tabVc.viewControllers![1]
				if vc.isKind(of: UINavigationController.classForCoder()) {
					let nav:UINavigationController = vc as! UINavigationController
					nav.viewControllers = [ChatLoginViewController(),TelegramConfirmViewController()]
					
					let vc = SWTabBarController.loginNavigationController()
					nav.present(vc!, animated: true, completion: nil)
				}
				
			}
			
			self.navigationController?.popViewController(animated: false)
			
		}
    }
    @IBAction func moreButtonClick(_ sender: Any) {
        let moreVC = MoreViewController()
        self.navigationController?.pushViewController(moreVC, animated: true)
        
    }
	
}
