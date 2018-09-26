//
//  ManageWalletCell.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/6.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class ManageWalletCell: UITableViewCell {

    @IBOutlet weak var backImgView: UIImageView!
//    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var AddressLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
	@IBOutlet weak var backUpBtn: UIButton!
	
	var clickBackUpClosure:(()->())?
	override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
		
		self.backUpBtn.setTitle(SWLocalizedString(key: "wallet_buckup_title"), for: UIControlState.normal)
    }

	@IBAction func clickBackBtn(_ sender: Any) {
		
		if clickBackUpClosure != nil {
			clickBackUpClosure!()
		}
		
	}
	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureBackImage(imgName:String) {
        self.backImgView.image = UIImage.init(named: imgName)
    }
    
    func configureContent(model:SwiftWalletModel) {
        self.titleLbl.text = model.walletName
        self.amountLbl.text = "--"
        self.AddressLbl.text = model.extendedPublicKey
//        self.unitLbl.text = model.coinType?.rawValue
        if let amount = model.totalAssets?.description {
            self.configureAmount(amount: amount)
        }
        if model.backgroundColor != nil {
            self.backImgView.image = UIImage.init(named: model.backgroundColor!)
        }
//        if model.walletImage != nil {
//            self.iconImgView.image = UIImage.init(named: model.walletImage!)
//        }
        if model.isBackUp != nil {
            self.backUpBtn.isHidden = model.isBackUp!
        }
    }
    
    func configureAmount(amount:String) {
        var balanceStr = "0.0"
        if let decim = Decimal(string: amount) {
            if decim < 10000000000 {
                balanceStr = String(decim.description.prefix(10))
            } else {
                balanceStr = decim.description
            }
        }
        let str = balanceStr
        self.amountLbl.text = SwiftExchanger.shared.currencySymbol + String(str)
    }
    
}
