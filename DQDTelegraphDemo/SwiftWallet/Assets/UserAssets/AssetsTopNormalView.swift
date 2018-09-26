//
//  AssetsTopNormalView.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/22.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsTopNormalView: UIView {
    
    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var totalAssetsLabel: UILabel!
    var walletModel: SwiftWalletModel? {
        didSet {
            if walletModel != nil {
                self.iconImgView.image = UIImage.init(named: walletModel!.walletImage!)
                self.nameLbl.text = walletModel!.walletName
                var backImgStr = ""
                if let back = walletModel?.backgroundColor {
                    backImgStr = back + "_normal"
                } else {
                    backImgStr = "assets_topBackView_1_normal"
                }
                self.backImgView.image = UIImage.init(named: backImgStr)
				
				if (walletModel!.totalAssets != nil){
                    self.amountLbl.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: walletModel!.totalAssets!, inDollar: false, short: false)// SwiftExchanger.shared.currencySymbol + " " + (walletModel!.totalAssets?.description)!
				}
            }
        }
    }

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    override func awakeFromNib() {
		super.awakeFromNib()
        totalAssetsLabel.text = SWLocalizedString(key: "assets_main_total_assets_text")
	}

}
