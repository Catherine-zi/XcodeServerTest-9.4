//
//  MyAccountViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/6/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class MyAccountViewController: UIViewController {
    @IBOutlet weak var navTitleLabel: UILabel!


	@IBOutlet weak var contentView: UIView!
	override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitleLabel.text = SWLocalizedString(key: "my_account")
//        self.tipLb.text = SWLocalizedString(key: "my_login_tips1")
		
		
		guard let phoneNumber = TelegramUserInfo.shareInstance.phoneNumber,
			  let firstName = TelegramUserInfo.shareInstance.firstName,
			  let userName = TelegramUserInfo.shareInstance.userName else {
			return;
		}
		
    }

	@IBAction func clickBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

}
