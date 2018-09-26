//
//  BackUpSuccessView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class BackUpSuccessView: UIView {

    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    
    var confirmBlock:(()->())?
	override func awakeFromNib() {
		super.awakeFromNib()
		self.successLabel.text = SWLocalizedString(key: "backup_successfully")
        self.tipLabel.text = SWLocalizedString(key: "keep_mnemonic")
        self.okBtn.setTitle(SWLocalizedString(key: "understand"), for: .normal)
		self.layer.cornerRadius = 5
		self.layer.masksToBounds = true
	}

	@IBAction func clickConfirmBtn(_ sender: UIButton) {
		if confirmBlock != nil {
			confirmBlock!()
		}
	}
}
