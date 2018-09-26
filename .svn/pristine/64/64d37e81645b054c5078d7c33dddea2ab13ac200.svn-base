//
//  SetKeystorePasswordCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/30.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SetKeystorePasswordCell: UITableViewCell {

    @IBOutlet weak var textfield: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.selectionStyle = .none
        self.textfield.placeholder = SWLocalizedString(key: "walle_import_wallet_key_store_password")
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
