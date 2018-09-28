//
//  CreateWalletDetailViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/27.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD
//import EthereumKit

class CreateWalletDetailViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var createBtn: UIButton!

	@IBOutlet weak var tipLabel2: UILabel!
	@IBOutlet weak var tipLabel1: UILabel!
	@IBOutlet weak var mainTab: UITableView!
    var typeCell: ChooseCoinTypeCell?
    var nameCell: InputWalletNameCell? {
        didSet {
            if nameCell != nil && oldValue == nil {
                nameCell!.walletName.delegate = self
            }
        }
    }
    var pwCell: SetWalletPassword? {
        didSet {
            if pwCell != nil && oldValue == nil {
                pwCell!.passwordTF.delegate = self
                pwCell!.confirmPwdTF.delegate = self
            }
        }
    }
    var agreeCell: AgreeServicePolicyCell? {
        didSet {
            if agreeCell != nil && oldValue == nil {
                agreeCell?.selectBtn.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
            }
        }
    }
	
	private var errorTipsView:CreateWalletErrorTipsView?
	
	override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_CreateWallet_Page)

		setUpView()
    }

	private func setUpView(){
		self.navTitleLabel.text = SWLocalizedString(key: "assets_create_text")
        self.createBtn.setTitle(SWLocalizedString(key: "wallet_create"), for: .normal)
        
		let tap:UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap(ges:)))
		self.view.addGestureRecognizer(tap)
		
		self.tipLabel2.text = SWLocalizedString(key: "wallet_create_detail_title2")
		self.tipLabel1.text = SWLocalizedString(key: "wallet_create_detail_title1")
		
		self.mainTab.delegate = self
		self.mainTab.dataSource = self
		
		self.mainTab.register(UINib.init(nibName: "ChooseCoinTypeCell", bundle: nil), forCellReuseIdentifier: "ChooseCoinTypeCell")
		self.mainTab.register(UINib.init(nibName: "InputWalletNameCell", bundle: nil), forCellReuseIdentifier: "InputWalletNameCell")
		self.mainTab.register(UINib.init(nibName: "SetWalletPassword", bundle: nil), forCellReuseIdentifier: "SetWalletPassword")
		self.mainTab.register(UINib.init(nibName: "AgreeServicePolicyCell", bundle: nil), forCellReuseIdentifier: "AgreeServicePolicyCell")
		self.mainTab.estimatedRowHeight = 100
		
		self.mainTab.separatorStyle = .none
		self.mainTab.backgroundColor = UIColor.init(hexColor: "F2F2F2")
	}
	
	@objc private func tap(ges:UITapGestureRecognizer){
		UIApplication.shared.keyWindow?.endEditing(false)
	}
	
	@IBAction func clickBackBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_CreateWallet_Page)
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func createWalletBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Create_CreateWallet_Page)
		
		//judge
		if judgeValue() {
			
			guard let coinTypeCell = self.typeCell,
			let nameCell:InputWalletNameCell = self.nameCell,
                let pwdCell:SetWalletPassword = self.pwCell else {
                    return
            }
			
			//create wallet
			let coinType = CoinType(rawValue: coinTypeCell.typeName.titleLabel?.text ?? "ETH") ?? .ETH
			
			let result = SwiftWalletManager.shared.createWalletByMnemonic(extendMnemonic: nil, walletName: nameCell.walletName.text, pwd: pwdCell.passwordTF.text!, coinType: coinType)
			
			if result.0 {
                SPUserEventsManager.shared.trackEventAction(SWUEC_Choose_Currency_Type, eventPrame: coinType.rawValue)
                if let model = result.3 {
                    SwiftNotificationManager.shared.addNotification(wallet: model)
                }
				let vc:BackUpWalletViewController = BackUpWalletViewController()
//                vc.mnemonic = result.1
//                vc.password = pwdCell.passwordTF.text!
                vc.walletModel = result.3
				vc.hidesBottomBarWhenPushed = true
                var controllers = self.navigationController?.viewControllers
                controllers?.removeLast()
                controllers?.append(vc)
                if controllers != nil {
                    self.navigationController?.setViewControllers(controllers!, animated: true)
                }
				
			}else {
				
				if result.2 {
					//存储失败，删除，需要重新创建
					SwiftWalletManager.shared.walletArr.removeLast()
					
					createWalletFailed()
				}
			}
		}		
	}
	
	private func createWalletFailed() {
		self.noticeOnlyText(SWLocalizedString(key: "add_failure"))
	}
	private func judgeValue() -> Bool {
		
		
		guard let nameCell:InputWalletNameCell = self.nameCell,
		let pwdCell:SetWalletPassword = self.pwCell,
		let agreeCell:AgreeServicePolicyCell = self.agreeCell
		else {
			return false
		}
		
		//judge
		if nameCell.walletName.text.lengthOfBytes(using: String.Encoding.utf8) == 0 {
			errorTipsView?.errorTipLB.text = SWLocalizedString(key: "wallet_name_empty")
			nameCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			nameCell.cornerRadiusView.layer.borderWidth = 2
			return false
		}
		if nameCell.walletName.text.lengthOfBytes(using: String.Encoding.utf8) > 20 {
            errorTipsView?.errorTipLB.text = SWLocalizedString(key:"wallet_wallet_name_hint")
			nameCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			nameCell.cornerRadiusView.layer.borderWidth = 2
			return false
		}
		//recover
		nameCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
		nameCell.cornerRadiusView.layer.borderWidth = 0
		
		
		if pwdCell.passwordTF.text?.lengthOfBytes(using: String.Encoding.utf8) == 0 ||
			(pwdCell.passwordTF.text?.lengthOfBytes(using: String.Encoding.utf8))! < 8 || pwdCell.passwordTF.text != pwdCell.confirmPwdTF.text{
			
			errorTipsView?.errorTipLB.text = SWLocalizedString(key: "inconsistent_passwords_entered")
			pwdCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			pwdCell.cornerRadiusView.layer.borderWidth = 2
			return false
		}
		pwdCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
		pwdCell.cornerRadiusView.layer.borderWidth = 0
		
		
		
		
		
		errorTipsView?.errorTipLB.text = ""
		return true
	}
	
	//UITextFieldDelegate
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//
//        return true
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        if (errorTipsView?.errorTipLB.text?.lengthOfBytes(using: String.Encoding.utf8))! > 0 {
//            let _ = judgeValue()
//        }
//    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = (textField.text?.count)! - range.length + string.count
        judgeSubmitableFrom(field: textField, length: length)
		
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let length = (textView.text?.count)! - range.length + text.count
        judgeSubmitableFrom(field: textView, length: length)
		if textView == nameCell?.walletName {
			if length > 20 {
				return false
			}
		}
        return true
    }
    
    private func judgeSubmitableFrom(field: UIView?, length: Int) {
        guard let pField = self.pwCell!.passwordTF,
            let paField = self.pwCell!.confirmPwdTF,
            let nField = self.nameCell!.walletName,
			let serviceCell = self.agreeCell,
            let aBtn = serviceCell.selectBtn else {
                return
        }
        let pArr = [pField, paField]
        let nArr = [nField]
        for object in pArr {
            if object == field {
                if length < 8 {
                    self.enableSubmitBtn(enable: false)
                    return
                }
            } else {
                if object.text!.count < 8 {
                    self.enableSubmitBtn(enable: false)
                    return
                }
            }
        }
        for object in nArr {
            if object == field {
                if length < 1 {
                    self.enableSubmitBtn(enable: false)
                    return
                }
            } else {
                if object.text!.count < 1 {
                    self.enableSubmitBtn(enable: false)
                    return
                }
            }
        }
        if !aBtn.isSelected {
            self.enableSubmitBtn(enable: false)
            return
        }
        self.enableSubmitBtn(enable: true)
    }
    
    private func enableSubmitBtn(enable:Bool) {
        
        if enable && (agreeCell?.selectBtn.isSelected == true) {
            self.createBtn.backgroundColor = UIColor.init(hexColor: "1E59F5")
            self.createBtn.isEnabled = true
        } else {
            self.createBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")
            self.createBtn.isEnabled = false
        }
    }
    
    @objc private func agreeTapped() {
        judgeSubmitableFrom(field: nil, length: 0)
    }
	
	//UITableViewDataSource & UITableViewDelegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 3 ? errorTipH : 16
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let headV = (section == 3) ? CreateWalletErrorTipsView() : UIView()
		if section == 3 {
			errorTipsView = (headV as! CreateWalletErrorTipsView)
		}
		headV.backgroundColor = self.mainTab.backgroundColor
		return headV
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.section {
		case 0:
			let cell:ChooseCoinTypeCell = tableView.dequeueReusableCell(withIdentifier: "ChooseCoinTypeCell") as! ChooseCoinTypeCell
            self.typeCell = cell
			return cell
		case 1:
			let cell:InputWalletNameCell = tableView.dequeueReusableCell(withIdentifier: "InputWalletNameCell") as! InputWalletNameCell
            self.nameCell = cell
			return cell
		case 2:
			let cell:SetWalletPassword = tableView.dequeueReusableCell(withIdentifier: "SetWalletPassword") as! SetWalletPassword
            self.pwCell = cell
			return cell
		case 3:
			let cell:AgreeServicePolicyCell = tableView.dequeueReusableCell(withIdentifier: "AgreeServicePolicyCell") as! AgreeServicePolicyCell
//            cell.contentView.backgroundColor = UIColor.red
            self.agreeCell = cell
			return cell
		default:
			return UITableViewCell()
		}
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		UIApplication.shared.keyWindow?.endEditing(false)
	}
}
