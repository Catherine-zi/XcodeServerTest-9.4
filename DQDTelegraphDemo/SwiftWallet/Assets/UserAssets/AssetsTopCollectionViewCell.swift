//
//  AssetsTopCollectionViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/20.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class AssetsTopCollectionViewCell: UICollectionViewCell {

	var model:SwiftWalletModel? {
		didSet {
			guard let model = model else {
				return
			}
//            walletLogoImageV.image = UIImage(named: model.walletImage!)
            if model.backgroundColor != nil {
                backImageV.image = UIImage(named: model.backgroundColor!)
            }
			walletNameLB.text = model.walletName
//            walletAddressLB.text = model.extendedPublicKey
            totalAssets.text = SwiftExchanger.shared.getFormattedCurrencyString(amount: (model.totalAssets ?? Decimal()), inDollar: false, short: false)//SwiftExchanger.shared.currencySymbol
                //+ " " + (SwiftExchanger.shared.convertLegalDecimal(currency: model.totalAssets) ?? "0.0")
            let totalCost = SwiftExchanger.shared.calculateTotalCost(wallet: model)
            if totalCost != 0 {
                self.totalCostAmountLbl.text = SwiftExchanger.shared.currencySymbol + SwiftExchanger.shared.getRoundedNumber(number: totalCost, decimalCount: 2).description
                if let totalAsset = model.totalAssets {
                    let str = SwiftExchanger.shared.getRoundedNumber(number: (totalAsset - totalCost), decimalCount: 2).description
                    self.totalProfitAmountLbl.text = SwiftExchanger.shared.getSignumMovedCurrencySymbolString(string: str)
                }
            } else {
                self.totalCostAmountLbl.text = "--"
                self.totalProfitAmountLbl.text = "--"
            }
            
            let str = SwiftExchanger.shared.getRoundedNumber(number: SwiftExchanger.shared.calculate24Profit(wallet: model), decimalCount: 2).description
            self.profit24hLbl.text = SWLocalizedString(key: "profit_24h") + " " + SwiftExchanger.shared.getSignumMovedCurrencySymbolString(string: str)
            
			if model.coinType == CoinType.ETH {
				addAssetBtn.isHidden = false
//                sepView.isHidden = true
			} else {
				addAssetBtn.isHidden = true
//                sepView.isHidden = false
			}
            if model.isBackUp != nil {
//                backUpBtn.isHidden = model.isBackUp!
            }
		}
	}
	
    @IBOutlet weak var backView: SWCornerRadiusView!
    @IBOutlet weak var backUpBtn: UIButton!
	@IBOutlet weak var backImageV: UIImageView!
//    @IBOutlet weak var walletLogoImageV: UIImageView!
	@IBOutlet weak var walletNameLB: UILabel!
//    @IBOutlet weak var walletAddressLB: UILabel!
	@IBOutlet weak var totalAssets: UILabel!
    @IBOutlet weak var profit24hLbl: UILabel!
    @IBOutlet weak var totalCostLbl: UILabel!
    @IBOutlet weak var totalCostAmountLbl: UILabel!
    @IBOutlet weak var totalProfitLbl: UILabel!
    @IBOutlet weak var totalProfitAmountLbl: UILabel!
    @IBOutlet weak var addAssetBtn: UIButton!
//    @IBOutlet weak var sepView: UIView!
	
//    @IBOutlet weak var totalTipl: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
		
//        self.totalTipl.text =  SWLocalizedString(key: "assets_main_total_assets_text")
        self.backImageV.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		self.backUpBtn.setTitle(SWLocalizedString(key: "wallet_buckup_title"), for: UIControlState.normal)
        self.totalCostLbl.text = SWLocalizedString(key: "total_cost")
        self.totalProfitLbl.text = SWLocalizedString(key: "total_profit")
		self.contentView.backgroundColor = UIColor.init(hexColor: "F2F2F2")
    }

	@IBAction func clickBackUp(_ sender: Any) {
		//跳到备份页
		let backUp = BackUpWalletViewController()
//        backUp.mnemonic = model?.mnemonic
//        backUp.password = model?.password
		backUp.walletModel = self.model
		backUp.hidesBottomBarWhenPushed = true
		self.viewController().navigationController?.pushViewController(backUp, animated: true)
	}
	@IBAction func clickAddBtn(_ sender: UIButton) {
		
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_AddAssets_Assets_Page)
		if model?.coinType != .ETH {
			return
		}
		let vc:SWAddAssetsViewController = SWAddAssetsViewController()
		vc.hidesBottomBarWhenPushed = true
		vc.model = model
        if self.viewController().isKind(of: AssetstViewController.classForCoder()) {
            let rootController:AssetstViewController = self.viewController() as! AssetstViewController
            vc.assetsType = rootController.tokenArray ?? []
        }
		self.viewController().navigationController?.pushViewController(vc, animated: true)
	}
	@IBAction func clickScanBtn(_ sender: UIButton) {
		
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_QRCode_Assets_Page)

		let createWalletVC = GenerateQRCodeViewController.init(nibName: "GenerateQRCodeViewController", bundle: nil)
		createWalletVC.view.backgroundColor = UIColor.white.withAlphaComponent(0)
//		createWalletVC.transitioningDelegate = self
		createWalletVC.modalPresentationStyle = .custom
//        createWalletVC.walletAddressLabel.text = model?.extendedPublicKey
        createWalletVC.walletAddress = model?.extendedPublicKey
        createWalletVC.receivingCodeLabel.text = model?.walletName
        if let img = model?.walletImage {
            createWalletVC.logoImageView.image = UIImage.init(named: img)
        }
		self.viewController().present(createWalletVC, animated: true, completion: nil)
	}
}
