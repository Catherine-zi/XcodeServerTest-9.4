//
//  ExchangeDetailTableViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ExchangeDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
		
		if  SWScreen_width == 320 {
			fitSEVolW.constant = 46
			fitSEnameRightMargin.constant = 0
		}
    }

	@IBOutlet weak var fitSEVolW: NSLayoutConstraint!
	@IBOutlet weak var fitSEnameRightMargin: NSLayoutConstraint!
	
	@IBOutlet weak var backView: UIView!
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var pairNameLabel: UILabel!
    @IBOutlet weak var exchangeNameLabel: UILabel!
    @IBOutlet weak var volume24hLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentExchangeLabel: UILabel!

    
    public func fillDataWithSymbolStruct(detailStruct: MarketsExchangeDetailDataStruct, indexPath: IndexPath) {
		
		if var urlStr = detailStruct.icon {
			urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
			if let url:URL = URL.init(string: urlStr) {
				self.coinIcon.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
			}else {
				self.coinIcon.image = UIImage.init(named: "placeholderIcon")
			}
		}else {
			self.coinIcon.image = UIImage.init(named: "placeholderIcon")
		}

        self.pairNameLabel.text = detailStruct.pair
        self.exchangeNameLabel.text = detailStruct.currencyName
        if let priceStr = detailStruct.priceUsd,
            let priceDecim = Decimal(string: priceStr) {
            self.priceLabel.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: priceDecim, inDollar: true, short: false)
        } else {
            self.priceLabel.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: Decimal(), inDollar: true, short: false)
        }
        self.percentExchangeLabel.text = detailStruct.volumePercentExchange ?? "0.0" + "%"
        if let volumeStr = detailStruct.volumeUsd24h,
            let volumeDecim = Decimal(string: volumeStr) {
            self.volume24hLabel.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: volumeDecim, inDollar: true, short: false)
        } else {
            self.volume24hLabel.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: Decimal(), inDollar: true, short: false)
        }
    }
}
