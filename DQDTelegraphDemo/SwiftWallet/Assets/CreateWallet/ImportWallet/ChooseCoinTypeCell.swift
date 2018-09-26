//
//  ChooseCoinTypeCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ChooseCoinTypeCell: UITableViewCell {

	@IBOutlet weak var typeName: UIButton!
    @IBOutlet weak var coinTypeLabel: UILabel!
    
	override func awakeFromNib() {
        super.awakeFromNib()
		self.coinTypeLabel.text = SWLocalizedString(key: "wallet_coin_type")
		self.selectionStyle = .none
    }

	@IBAction func didClickChooseType(_ sender: UIButton) {
		
		let vc = SelectCoinTypeViewController()
		vc.selectTypeClosure = {[weak self](count:Int) in
			self?.typeName.setTitle(count == 0 ? "BTC" : "ETH", for: UIControlState.normal)
		}
		self.viewController().navigationController?.pushViewController(vc, animated: true)
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
