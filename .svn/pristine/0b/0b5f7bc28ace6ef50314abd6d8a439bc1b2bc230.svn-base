//
//  LogoutConfirmView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/6/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class LogoutConfirmView: UIView {

	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.layer.cornerRadius = 5
		self.layer.masksToBounds = true
		
		self.tipLB.text = SWLocalizedString(key: "log_out_bitPub_dialog_text")
		self.confirmBtn.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), for: .normal)
		self.cancelBtn.setTitle(SWLocalizedString(key: "log_out_bitPub_dialog_confirm"), for: .normal)
	
	}
	@IBOutlet weak var tipLB: UILabel!
	@IBOutlet weak var cancelBtn: UIButton!
	@IBOutlet weak var confirmBtn: UIButton!
	
	typealias CancelbBlock = () -> ()
	typealias ConfirmBlock = () -> ()
	var cancelBlock:CancelbBlock?
	var confirmBlock:ConfirmBlock?
	
	//click confirm
	@IBAction func clickCancel(_ sender: UIButton) {
		if confirmBlock != nil {
			confirmBlock!()
		}
	}
	
	//click cancel
	@IBAction func clickConfirm(_ sender: UIButton) {
		
		if cancelBlock != nil {
			cancelBlock!()
		}
	}
	
}
