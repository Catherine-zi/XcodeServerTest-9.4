//
//  BackUpVerifyPwdView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/24.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class BackUpVerifyPwdView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!

    override func awakeFromNib() {
		super.awakeFromNib()
		self.titleLabel.text = SWLocalizedString(key: "input_password_alert")
        self.cancelBtn.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), for: .normal)
        self.confirmBtn.setTitle(SWLocalizedString(key: "wallet_confirm"), for: .normal)

        
		self.layer.cornerRadius = 5
		self.layer.masksToBounds = true
	}

	typealias CancelbBlock = () -> ()
	typealias ConfirmBlock = (String) -> Bool
	typealias DeleteWalletBlock = () -> ()
	var cancelBlock:CancelbBlock?
	var confirmBlock:ConfirmBlock?
	var deleteWalletBlock:DeleteWalletBlock?
	private var errorTime:Int = 5//一共五次机会
	@IBOutlet weak var pwdInput: UITextField!
	
	@IBAction func clickConfirm(_ sender: UIButton) {
		
		if (pwdInput.text?.lengthOfBytes(using: String.Encoding.utf8))! > 0 && (confirmBlock != nil){
			
			let result:Bool = confirmBlock!(pwdInput.text!)
			if !result {
				errorTime = errorTime - 1
                errorTips.text = String.init(format: SWLocalizedString(key: "password_wrong"), errorTime)
//                errorTips.text = "WRONG PASSWORD,YOU HAVE LEFT \(errorTime) TIMES! OR YOUR WALLET WILL BE INVALID."
				pwdInput.text = ""
				
				if errorTime == 0 {
					//删除当前的钱包
					if (deleteWalletBlock != nil){
						deleteWalletBlock!()
					}
					return
				}
			}
		}
		
	}
	
	@IBOutlet weak var errorTips: UILabel!
	
	@IBAction func clickCancel(_ sender: UIButton) {
		if cancelBlock != nil {
			cancelBlock!()
		}
		
	}
}
