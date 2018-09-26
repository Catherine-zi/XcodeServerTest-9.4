//
//  AssetsMainTableViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsMainTableViewCell:MGSwipeTableCell  {//SwipeTableViewCell



    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headImageV: UIImageView!
	@IBOutlet weak var coinNameL: UILabel!
	@IBOutlet weak var transactionL: UILabel!
	@IBOutlet weak var valueL: UILabel!
    @IBOutlet weak var changeRateLbl: UILabel!
    @IBOutlet weak var changeAmountLbl: UILabel!
    
	var model:AssetsTokensModel? {
		didSet {
            coinNameL.text = model?.symbol
            var balanceStr = "0.0"
            if model?.balance != nil {
                if model!.balance! < 10000000000 {
                    balanceStr = String(model!.balance!.description.prefix(10))
                } else {
                    balanceStr = model!.balance!.description
                }
            }
            transactionL.text = balanceStr
            valueL.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: (model?.balanceInLegal ?? Decimal()), inDollar: false, short: false)//SwiftExchanger.shared.currencySymbol + " " + (SwiftExchanger.shared.convertLegalDecimal(currency: model?.balanceInLegal) ?? "0.0")
			
			if  let symbol = model?.symbol,
                let image = UIImage.init(named: symbol)
            {
				headImageV.image = image
            } else {

                guard var urlStr = model?.iconUrl, urlStr.count > 0 else {
                    self.headImageV.image = UIImage.init(named: "placeholderIcon")
                    return
                }
				urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
                headImageV.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
			}

			
		}
	}
	override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
