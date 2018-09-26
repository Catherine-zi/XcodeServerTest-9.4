//
//  BackUpWalletViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/2.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class BackUpWalletViewController: UIViewController {
    
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var backupBtn: UIButton!

//    var mnemonic:[String]?
//    var password:String?
    var walletModel:SwiftWalletModel?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_BackupPrompt_Page)
        self.navTitleLabel.text = SWLocalizedString(key: "wallet_buckup_title")
        self.titleTextLabel.text = SWLocalizedString(key: "wallet_buckup_message")
        self.attentionLabel.text = SWLocalizedString(key: "wallet_attention_title")
        self.backupBtn.setTitle(SWLocalizedString(key: "wallet_backup_now"), for: .normal)
       
        
        let tips1 = SWLocalizedString(key: "wallet_attention_message1")
        let tips2 = String(format: SWLocalizedString(key: "wallet_attention_message2"), SWLocalizedString(key: "wallet_attention_message2_submsg"))
        let tips3 = String(format: SWLocalizedString(key: "wallet_attention_message3"), SWLocalizedString(key: "wallet_attention_message3_submsg"))

        let tips4 = String(format: SWLocalizedString(key: "wallet_attention_message4"), SWLocalizedString(key: "wallet_attention_message4_submsg"))

        let tips :NSString = String(format: "%@\n%@\n%@\n%@", arguments: [tips1,tips2,tips3,tips4]) as NSString

        let range1:NSRange = tips.range(of: SWLocalizedString(key: "wallet_attention_message2_submsg"))
        let range2:NSRange = tips.range(of: SWLocalizedString(key: "wallet_attention_message3_submsg"))
        let range3:NSRange = tips.range(of: SWLocalizedString(key: "wallet_attention_message4_submsg"))

        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 10
		paragraphStyle.paragraphSpacing = 3
		
        let attributes = NSMutableAttributedString.init(string: tips as String, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),NSAttributedStringKey.foregroundColor : UIColor.init(red: 170, green: 170, blue: 170),NSAttributedStringKey.paragraphStyle : paragraphStyle])
        
        attributes.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], range:range1)
        attributes.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], range:range2)
        attributes.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], range:range3)

        tipTextView.attributedText = attributes

		
		
    }

	@IBAction func clickBackBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_BackupNow_BackupPrompt_Page)
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBOutlet weak var tipTextView: UITextView!
	
	@IBAction func clickBackUpNowBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_BackupNow_BackupPrompt_Page)
		
		let verifyView = Bundle.main.loadNibNamed("BackUpVerifyPwdView", owner: nil, options: nil)?.first as! BackUpVerifyPwdView
		verifyView.frame = VisualEffectView.subFrame
		let visualView = VisualEffectView.visualEffectView(frame:view.bounds)
		visualView.contentView.addSubview(verifyView)
		view.addSubview(visualView)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WalletPassword_Popup)
		
		verifyView.deleteWalletBlock = {[weak self,weak visualView] in
            guard let privKeyHash = self?.walletModel?.extendedPrivateKey
            else {
                return
            }
			let suc = SwiftWalletManager.shared.removeWallet(privateKeyHash: privKeyHash)
			if suc {
                SwiftNotificationManager.shared.removeNotification(wallet: self!.walletModel!, registrationId: nil)
				visualView?.removeFromSuperview()
				self?.navigationController?.popViewController(animated: true)
			}
		}
		verifyView.cancelBlock = { [weak visualView] in
			visualView?.removeFromSuperview()
		}
		verifyView.confirmBlock = {[weak self,weak visualView] (pwd:String) in
            guard let password = self?.walletModel?.password else {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WrongPassword_Prompt_CreateWallet_Page)
                return false
            }
			if pwd == SwiftWalletManager.shared.normalDecrypt(string: password) {
				
				visualView?.removeFromSuperview()
				let vc:GenerateMnemonicViewController = GenerateMnemonicViewController()
//                vc.mnemonic = self?.walletModel?.mnemonic
                vc.walletModel = self?.walletModel
				self?.navigationController?.pushViewController(vc, animated: true)
				
				return true
			}
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WrongPassword_Prompt_CreateWallet_Page)
			return false
		}
		verifyView.pwdInput.becomeFirstResponder()
		
	}
   
}










