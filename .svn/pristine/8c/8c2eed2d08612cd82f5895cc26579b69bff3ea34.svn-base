//
//  SendDetailViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/27.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SendDetailViewController: UIViewController {
    
    var walletModel: SwiftWalletModel?
    var inputModel: TransferAccountsViewController.TransactionInputModel?

    @IBOutlet weak var receiverAddressLabel: UILabel!
    @IBOutlet weak var minningFeeLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var backgroundView: UIView!
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
		self.amountLabel.text = self.inputModel?.amount
//        self.memoLabel.text = self.inputModel?.memo
		if self.walletModel?.coinType == CoinType.BTC {
            switch self.inputModel?.btcFee {
            case .slow?:
                self.minningFeeLabel.text = "慢"
            case .some(.normal):
                self.minningFeeLabel.text = "正常"
            case .some(.fast):
                self.minningFeeLabel.text = "快"
            case .none:
                self.minningFeeLabel.text = ""
            }
		} else if self.walletModel?.coinType == CoinType.ETH {
			self.minningFeeLabel.text = self.inputModel?.ethFee
		}
        
    }
    @IBAction func nextButtonClick(_ sender: UIButton) {
        let pswVC = WalletPswViewController.init(nibName: "WalletPswViewController", bundle: nil)
        pswVC.walletModel = self.walletModel!
        pswVC.inputModel = self.inputModel!
        pswVC.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        pswVC.modalPresentationStyle = .custom
        self.present(pswVC, animated: false, completion: nil)
		self.backgroundView.isHidden = true

//        self.navigationController?.pushViewController(pswVC, animated: true)
        
    }
    @IBAction func closeButtonClick(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
	
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}
