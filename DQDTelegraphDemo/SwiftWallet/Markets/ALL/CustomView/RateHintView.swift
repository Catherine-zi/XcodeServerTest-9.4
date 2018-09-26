//
//  BackUpSuccessView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/23.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class RateHintView: UIView {

    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    
    var confirmBlock:(()->())?
	override func awakeFromNib() {
		super.awakeFromNib()
		self.successLabel.text = SWLocalizedString(key: "formula")
        self.tipLabel.text = SWLocalizedString(key: "rate_formula")
        self.okBtn.setTitle(SWLocalizedString(key: "close"), for: .normal)
		self.layer.cornerRadius = 5
		self.layer.masksToBounds = true
	}

	@IBAction func clickConfirmBtn(_ sender: UIButton) {
		if confirmBlock != nil {
			confirmBlock!()
		}
	}
}
