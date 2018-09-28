//
//  SendDetailViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/27.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class SendDetailViewController: UIViewController {
    
    var walletModel: SwiftWalletModel?
    var inputModel: TransferAccountsViewController.TransactionInputModel?

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var receiAddTitleLabel: UILabel!
    @IBOutlet weak var minFeeTitleLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!

    @IBOutlet weak var receiverAddressLabel: UILabel!
    @IBOutlet weak var minningFeeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var backgroundView: UIView!
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_SendDetailConfirm_Page)
        navTitleLabel.text = SWLocalizedString(key: "send_detail")
        receiAddTitleLabel.text = SWLocalizedString(key: "receiver_address")
        minningFeeLabel.text = SWLocalizedString(key: "mining_fee")
        amountLabel.text = SWLocalizedString(key: "amount")
        nextBtn.setTitle(SWLocalizedString(key: "next"), for: .normal)

        self.loadUIContent()
        NotificationCenter.default.addObserver(self, selector: #selector(closeButtonClick), name: SWNotificationName.dismissTransactionVc.notificationName, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(closeButtonClick), name: SWNotificationName.dismissSendDetailVc.notificationName, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadUIContent() {
//        let miningFee = 0.003
//        let coinName = "ETH"
//        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        self.view.backgroundColor = UIColor.clear

        self.receiverAddressLabel.text = self.inputModel?.address
		self.amountLabel.text = (self.inputModel?.amount ?? "0.0") + " " + (self.inputModel?.unit ?? "")
        if let type = self.walletModel?.coinType {
            switch type {
            case .BTC:
                switch self.inputModel?.btcFee {
                case .slow?:
                    self.minningFeeLabel.text = SWLocalizedString(key: "slow")
                case .some(.normal):
                    self.minningFeeLabel.text = SWLocalizedString(key: "normal")
                case .some(.fast):
                    self.minningFeeLabel.text = SWLocalizedString(key: "fast")
                case .none:
                    self.minningFeeLabel.text = ""
                }
            case .LTC:
                switch self.inputModel?.ltcFee {
                case .slow?:
                    self.minningFeeLabel.text = SWLocalizedString(key: "slow")
                case .some(.normal):
                    self.minningFeeLabel.text = SWLocalizedString(key: "normal")
                case .some(.fast):
                    self.minningFeeLabel.text = SWLocalizedString(key: "fast")
                case .none:
                    self.minningFeeLabel.text = ""
                }
            case .ETH:
                self.minningFeeLabel.text = (self.inputModel?.ethFee ?? "0.0") + " " + "ETH"
            }
        }
//        if self.walletModel?.coinType == CoinType.BTC {
//            switch self.inputModel?.btcFee {
//            case .slow?:
//                self.minningFeeLabel.text = SWLocalizedString(key: "slow")
//            case .some(.normal):
//                self.minningFeeLabel.text = SWLocalizedString(key: "normal")
//            case .some(.fast):
//                self.minningFeeLabel.text = SWLocalizedString(key: "fast")
//            case .none:
//                self.minningFeeLabel.text = ""
//            }
//        } else if self.walletModel?.coinType == CoinType.ETH {
//            self.minningFeeLabel.text = (self.inputModel?.ethFee ?? "0.0") + " " + "ETH"
//        }
        
    }
    @IBAction func nextButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_SendDetailConfirm_Page)
        let pswVC = WalletPswViewController.init(nibName: "WalletPswViewController", bundle: nil)
        if self.walletModel == nil || self.inputModel == nil {
            self.noticeOnlyText(SWLocalizedString(key: "network_error"))
            return
        }
        pswVC.walletModel = self.walletModel!
        pswVC.inputModel = self.inputModel!
        pswVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        pswVC.modalPresentationStyle = .custom
        self.present(pswVC, animated: false, completion: nil)
		self.backgroundView.isHidden = true

//        self.navigationController?.pushViewController(pswVC, animated: true)
        
    }
    @IBAction func closeButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_SendDetailConfirm_Page)
        self.dismiss(animated: false, completion: nil)
    }
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}
