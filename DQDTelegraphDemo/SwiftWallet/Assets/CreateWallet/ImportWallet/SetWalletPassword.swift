//
//  SetWalletPassword.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SetWalletPassword: UITableViewCell {

    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    
    @IBOutlet weak var passwordTF: UITextField!
	@IBOutlet weak var confirmPwdTF: UITextField!
	@IBOutlet weak var cornerRadiusView: SWCornerRadiusView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		self.title1Label.text = SWLocalizedString(key: "wallet_set_password")
        self.title2Label.text = SWLocalizedString(key: "wallet_confirm_password")
        self.passwordTF.placeholder = SWLocalizedString(key: "wallet_set_password_hint")
        self.confirmPwdTF.placeholder = SWLocalizedString(key: "repeat_password")
		self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		self.contentView.backgroundColor = superview?.backgroundColor
	}
}
