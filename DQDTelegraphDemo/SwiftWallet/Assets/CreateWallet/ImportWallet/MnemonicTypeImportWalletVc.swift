//
//  MnemonicTypeImportWalletVc.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/30.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class MnemonicTypeImportWalletVc: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate {
	
    var typeCell: ChooseCoinTypeCell?
    var mnemCell: InputContentCell? {
        didSet {
            if mnemCell != nil && oldValue == nil {
                mnemCell?.textView.delegate = self
            }
        }
    }
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
    var startBtn: UIButton = UIButton()
	private var errorTipsView:CreateWalletErrorTipsView?
	private lazy var tab:UITableView = {
		
		var tabFrame:CGRect = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: (SWScreen_height - SafeAreaTopHeight - 44 - 50 - ((SWScreen_height == 812.0) ? iPhoneXBottomHeight : 0)))
		let tab:UITableView = UITableView.init(frame: tabFrame, style: UITableViewStyle.plain)
		
		tab.delegate = self
		tab.dataSource = self
		
		tab.register(UINib.init(nibName: "ChooseCoinTypeCell", bundle: nil), forCellReuseIdentifier: "ChooseCoinTypeCell")
		tab.register(UINib.init(nibName: "InputContentCell", bundle: nil), forCellReuseIdentifier: "InputContentCell")
//		tab.register(UINib.init(nibName: "MnemonicTypeCell", bundle: nil), forCellReuseIdentifier: "MnemonicTypeCell")
		tab.register(UINib.init(nibName: "InputWalletNameCell", bundle: nil), forCellReuseIdentifier: "InputWalletNameCell")
		tab.register(UINib.init(nibName: "SetWalletPassword", bundle: nil), forCellReuseIdentifier: "SetWalletPassword")
		tab.register(UINib.init(nibName: "AgreeServicePolicyCell", bundle: nil), forCellReuseIdentifier: "AgreeServicePolicyCell")
		tab.estimatedRowHeight = 100
		
		tab.separatorStyle = .none
		tab.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		
		let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap(gesture:)))
		tab.addGestureRecognizer(tap)
		
		return tab
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Import_Mnemonic_Page)
		
		setUpViews()
		
    }
	private func judgeValue() -> Bool {
		
		guard let coinTypeCell = self.typeCell,
			let mnemonicCell:InputContentCell = self.mnemCell,
			let walletNameCell:InputWalletNameCell = self.nameCell,
			let pwdCell:SetWalletPassword = self.pwCell,
			let agreeCell:AgreeServicePolicyCell = self.agreeCell
			else {
				return false
		}
		//veriry input (first UI，second can wallet)
		let arr = mnemonicCell.textView.text.components(separatedBy: " ")
		if arr.count != 12 {
			mnemonicCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			mnemonicCell.cornerRadiusView.layer.borderWidth = 2
			errorTipsView?.errorTipLB.text = SWLocalizedString(key: "invalid_mnemonic")
			return false
		}
        for wallet in SwiftWalletManager.shared.walletArr {
            if wallet.coinType?.rawValue == coinTypeCell.typeName.titleLabel?.text {
                let arr = mnemonicCell.textView.text.components(separatedBy: " ")
                if let arrData = try? JSONEncoder().encode(arr)
                {
                    if BTCSHA256(arrData).base58String() == wallet.mnemHash {
                        mnemonicCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
                        mnemonicCell.cornerRadiusView.layer.borderWidth = 2
                        errorTipsView?.errorTipLB.text = SWLocalizedString(key: "wallet_exists")
                        return false
                    }
                }
            }
        }
		mnemonicCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
		mnemonicCell.cornerRadiusView.layer.borderWidth = 0
		//wallet name
		if walletNameCell.walletName.text.lengthOfBytes(using: String.Encoding.utf8) == 0 {
			errorTipsView?.errorTipLB.text = SWLocalizedString(key: "no_wallet")
			walletNameCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			walletNameCell.cornerRadiusView.layer.borderWidth = 2
			return false
		}
		if walletNameCell.walletName.text.lengthOfBytes(using: String.Encoding.utf8) > 20 {
			errorTipsView?.errorTipLB.text = SWLocalizedString(key: "wallet_wallet_name_hint")
			walletNameCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			walletNameCell.cornerRadiusView.layer.borderWidth = 2
			return false
		}
		//recover
		walletNameCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
		walletNameCell.cornerRadiusView.layer.borderWidth = 0
		
		//pwd
		if pwdCell.passwordTF.text?.lengthOfBytes(using: String.Encoding.utf8) == 0 ||
			(pwdCell.passwordTF.text?.lengthOfBytes(using: String.Encoding.utf8))! < 8 ||			pwdCell.passwordTF.text != pwdCell.confirmPwdTF.text{
			
			errorTipsView?.errorTipLB.text = SWLocalizedString(key: "inconsistent_passwords_entered")
			pwdCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
			pwdCell.cornerRadiusView.layer.borderWidth = 2
			return false
		}
		pwdCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
		pwdCell.cornerRadiusView.layer.borderWidth = 0
		
		
		if !agreeCell.selectBtn.isSelected {
//            errorTipsView?.errorTipLB.text = "please Agree on Terms of service and Privacy Policy"
            errorTipsView?.errorTipLB.text = SWLocalizedString(key: "wallet_agree")
			return false
		}
		
		
		errorTipsView?.errorTipLB.text = ""
		return true
	}
	@objc private func startImport() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Start_Import_Mnemonic)
		
		if !judgeValue() {
			return
		}
		guard let coinTypeCell = self.typeCell,//tab.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChooseCoinTypeCell,
			let mnemonicCell:InputContentCell = self.mnemCell,
			let walletNameCell:InputWalletNameCell = self.nameCell,
			let pwdCell:SetWalletPassword = self.pwCell
			else {
				return
		}
		
        let coinType = CoinType(rawValue: coinTypeCell.typeName.titleLabel?.text ?? "ETH") ?? .ETH
		let arr = mnemonicCell.textView.text.components(separatedBy: " ")
		let result = SwiftWalletManager.shared.createWalletByMnemonic(extendMnemonic: arr, walletName: walletNameCell.walletName.text, pwd: pwdCell.passwordTF.text!, coinType: coinType)
		
		if result.0 {
            if let model = result.3 {
                SwiftNotificationManager.shared.addNotification(wallet: model)
                SwiftWalletManager.shared.updateHoldingToken(wallet: model)
            }
            if self.tabBarController != nil {
                if self.tabBarController?.selectedIndex != 2 {
                    for vc in (self.navigationController?.viewControllers)! {
                        if vc is ManageWalletViewController {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                } else {
                    if self.navigationController != nil {
                        self.navigationController?.viewControllers = [AssetstViewController()]
                    }
                }
            }
//            let vc:BackUpWalletViewController = BackUpWalletViewController()
////            vc.mnemonic = result.1
////            vc.password = pwdCell.passwordTF.text!
//            vc.walletModel = result.3
//            self.navigationController?.pushViewController(vc, animated: true)
			
		}else {
			
			if result.2 {
				//存储失败，删除，需要重新创建
				SwiftWalletManager.shared.walletArr.removeLast()
				
				createWalletFailed()
			}
		}
	}
	
	private func createWalletFailed() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Import_failure_Prompt)
//        self.noticeOnlyText("Import Wallet Failed")
        self.noticeOnlyText(SWLocalizedString(key: "no_wallet"))

	}
	
	private func setUpViews() {
	
		view.addSubview(tab)
		
		startBtn = UIButton.init(frame: CGRect.init(x: 0, y: tab.frame.size.height, width: SWScreen_width, height: 50))
		startBtn.addTarget(self, action: #selector(startImport), for: UIControlEvents.touchUpInside)
		startBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")
        startBtn.isEnabled = false
		startBtn.setTitle(SWLocalizedString(key: "walle_start_import"), for: UIControlState.normal)
		startBtn.setTitleColor(UIColor.white, for: .normal)
		startBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		view.addSubview(startBtn)
	}
	
	@objc private func tap(gesture:UITapGestureRecognizer){
		UIApplication.shared.keyWindow?.endEditing(false)
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
        guard let pCell = self.pwCell,
            let mCell = self.mnemCell,
            let nCell = self.nameCell,
            let aCell = self.agreeCell,
            let pField = pCell.passwordTF,
            let paField = pCell.confirmPwdTF,
            let kField = mCell.textView,
            let nField = nCell.walletName,
            let aBtn = aCell.selectBtn else {
                return
        }
        let pArr = [pField, paField]
        let nArr = [kField, nField]
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
        if enable {
            self.startBtn.backgroundColor = UIColor.init(hexColor: "1E59F5")
            self.startBtn.isEnabled = true
        } else {
            self.startBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")
            self.startBtn.isEnabled = false
        }
    }
    
    @objc private func agreeTapped() {
        judgeSubmitableFrom(field: nil, length: 0)
    }
	
	// UITableViewDelegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 5
	}
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 4 ? errorTipH : 16
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headV = (section == 4) ? CreateWalletErrorTipsView() : UIView()
		if section == 4 {
			errorTipsView = (headV as! CreateWalletErrorTipsView)
		}
		headV.backgroundColor = tab.backgroundColor
		return headV
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.section {
		case 0:
			let cell:ChooseCoinTypeCell = tableView.dequeueReusableCell(withIdentifier: "ChooseCoinTypeCell") as! ChooseCoinTypeCell
            self.typeCell = cell
			return cell
		case 1:
			let cell:InputContentCell = tableView.dequeueReusableCell(withIdentifier: "InputContentCell") as! InputContentCell
			cell.textView.placeholder = SWLocalizedString(key: "walle_import_wallet_message")
            self.mnemCell = cell
			return cell
//		case 2:
//			let cell:MnemonicTypeCell = tableView.dequeueReusableCell(withIdentifier: "MnemonicTypeCell") as! MnemonicTypeCell
//			return cell
		case 2:
			let cell:InputWalletNameCell = tableView.dequeueReusableCell(withIdentifier: "InputWalletNameCell") as! InputWalletNameCell
            self.nameCell = cell
			return cell
		case 3:
			let cell:SetWalletPassword = tableView.dequeueReusableCell(withIdentifier: "SetWalletPassword") as! SetWalletPassword
            self.pwCell = cell
			return cell
		case 4:
			let cell:AgreeServicePolicyCell = tableView.dequeueReusableCell(withIdentifier: "AgreeServicePolicyCell") as! AgreeServicePolicyCell
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
