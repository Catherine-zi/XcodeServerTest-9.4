//
//  SingleCoinTypeCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/30.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SingleCoinTypeCell: UITableViewCell {

    @IBOutlet weak var coinTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
		self.coinTypeLabel.text = SWLocalizedString(key: "wallet_coin_type")
		self.borderView.layer.borderColor = UIColor.init(hexColor: "dddddd").cgColor
		self.borderView.layer.borderWidth = 1
		self.selectionStyle = .none
    }

	@IBOutlet weak var borderView: SWCornerRadiusView!
	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		self.contentView.backgroundColor = superview?.backgroundColor
	}
}
