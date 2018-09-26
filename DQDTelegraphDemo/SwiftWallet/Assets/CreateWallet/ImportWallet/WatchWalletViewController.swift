//
//  ImportWalletViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/29.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class WatchWalletViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate {

    var typeCell: ChooseCoinTypeCell?
    var addressCell: WatchInputContentCell? {
        didSet {
            if addressCell != nil && oldValue == nil {
                addressCell?.textView.delegate = self
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
//    var pwCell: SetWalletPassword? {
//        didSet {
//            if pwCell != nil && oldValue == nil {
//                pwCell!.passwordTF.delegate = self
//                pwCell!.confirmPwdTF.delegate = self
//            }
//        }
//    }
    var agreeCell: AgreeServicePolicyCell? {
        didSet {
            if agreeCell != nil && oldValue == nil {
                agreeCell?.selectBtn.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
            }
        }
    }
    var startBtn: UIButton = UIButton()
    var scanString: String? {
        didSet {
            guard let addressCell:WatchInputContentCell = self.addressCell else {return}
            addressCell.textView.text = scanString
        }
    }
    private var errorTipsView:CreateWalletErrorTipsView?
    private lazy var tab:UITableView = {
        
        var tabFrame:CGRect = CGRect.init(x: 0, y: SWStatusBarH + SWNavBarHeight, width: SWScreen_width, height: (SWScreen_height - SafeAreaTopHeight - 50 - ((SWScreen_height == 812.0) ? iPhoneXBottomHeight : 0)))
        let tab:UITableView = UITableView.init(frame: tabFrame, style: UITableViewStyle.plain)
        
        tab.delegate = self
        tab.dataSource = self
        
        tab.register(UINib.init(nibName: "ChooseCoinTypeCell", bundle: nil), forCellReuseIdentifier: "ChooseCoinTypeCell")
        tab.register(UINib.init(nibName: "WatchInputContentCell", bundle: nil), forCellReuseIdentifier: "WatchInputContentCell")
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
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WatchWallet_Page)
        
		self.view.backgroundColor = UIColor.white
		
		setUpViews()
		
    }

	func setUpViews(){
		//NavView
		addNavView()
        
        view.addSubview(tab)
        
        startBtn = UIButton.init(frame: CGRect.init(x: 0, y: tab.frame.maxY, width: SWScreen_width, height: 50))
        startBtn.addTarget(self, action: #selector(startWatch), for: UIControlEvents.touchUpInside)
        startBtn.backgroundColor = UIColor.init(hexColor: "DCDCDC")//UIColor.init(red: 35, green: 89, blue: 245)
        startBtn.isEnabled = false
        startBtn.setTitle(SWLocalizedString(key: "wallet_watch"), for: UIControlState.normal)
        startBtn.setTitleColor(UIColor.white, for: .normal)
        startBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        view.addSubview(startBtn)
    }
	
	private func addNavView(){
		let navView:UIView = UIView.init(frame: CGRect.init(x: 0, y: SWStatusBarH, width: SWScreen_width, height: SWNavBarHeight))
		self.view.addSubview(navView)
		
		let backBtn:UIButton = UIButton.init()
		backBtn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
		backBtn.setImage(UIImage.init(named: "addAssets_back"), for: UIControlState.normal)
		
		let title:UILabel = UILabel.init()
		title.text = SWLocalizedString(key: "assets_watch_text")
        
        let scanBtn:UIButton = UIButton.init()
        scanBtn.addTarget(self, action: #selector(scan), for: UIControlEvents.touchUpInside)
        scanBtn.setImage(UIImage.init(named: "TransferAccounts_scanIcon"), for: UIControlState.normal)
        scanBtn.isHidden = true
		
		navView.addSubview(backBtn)
        navView.addSubview(scanBtn)
		navView.addSubview(title)
		
		backBtn.snp.makeConstraints { (make) in
			make.left.equalTo(navView).offset(16)
			make.centerY.equalTo(navView)
			make.height.width.equalTo(44)
		}
        scanBtn.snp.makeConstraints { (make) in
            make.right.equalTo(navView).offset(-16)
            make.centerY.equalTo(navView)
            make.height.width.equalTo(44)
        }
		title.snp.makeConstraints { (make) in
			make.centerY.centerX.equalTo(navView)
		}
		
	}
    
    private func judgeValue() -> Bool {
        
        guard let coinTypeCell:ChooseCoinTypeCell = self.typeCell,
            let addressCell:WatchInputContentCell = self.addressCell,
            let walletNameCell:InputWalletNameCell = self.nameCell,
//            let pwdCell:SetWalletPassword = self.pwCell,
            let agreeCell:AgreeServicePolicyCell = self.agreeCell,
            let typeStr = coinTypeCell.typeName.titleLabel?.text,
            let coinType = CoinType.init(rawValue: typeStr)
            else {
                return false
        }
        //veriry input (first UI，second can wallet)
        let address = addressCell.textView.text.replacingOccurrences(of: " ", with: "")
        var isAddressValid = false
        if coinType == CoinType.BTC {
            isAddressValid = SwiftWalletManager.shared.validateBtcAddress(address: address)
        } else if coinType == CoinType.ETH {
            isAddressValid = SwiftWalletManager.shared.validateEthAddress(address: address)
        }
        if !isAddressValid {
            addressCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
            addressCell.cornerRadiusView.layer.borderWidth = 2
            errorTipsView?.errorTipLB.text = SWLocalizedString(key: "address_not_valid")
            return false
        }
        for wallet in SwiftWalletManager.shared.walletArr {
            if wallet.coinType?.rawValue == coinTypeCell.typeName.titleLabel?.text {
                if wallet.extendedPublicKey == address {
                    addressCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
                    addressCell.cornerRadiusView.layer.borderWidth = 2
                    errorTipsView?.errorTipLB.text = SWLocalizedString(key: "wallet_watch_imported_address")
                    return false
                }
            }
        }
        addressCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
        addressCell.cornerRadiusView.layer.borderWidth = 0
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
        
//        //pwd
//        if pwdCell.passwordTF.text?.lengthOfBytes(using: String.Encoding.utf8) == 0 ||
//            (pwdCell.passwordTF.text?.lengthOfBytes(using: String.Encoding.utf8))! < 8 || pwdCell.passwordTF.text != pwdCell.confirmPwdTF.text{
//
//            errorTipsView?.errorTipLB.text = SWLocalizedString(key: "inconsistent_passwords_entered")
//            pwdCell.cornerRadiusView.layer.borderColor = errorColor.cgColor
//            pwdCell.cornerRadiusView.layer.borderWidth = 2
//            return false
//        }
//        pwdCell.cornerRadiusView.layer.borderColor = UIColor.white.cgColor
//        pwdCell.cornerRadiusView.layer.borderWidth = 0
        
        
        if !agreeCell.selectBtn.isSelected {
            errorTipsView?.errorTipLB.text = "please Agree on Terms of service and Privacy Policy"
            return false
        }
        
        errorTipsView?.errorTipLB.text = ""
        return true
    }
    
    @objc private func startWatch(){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_import_WatchWallet_Page)
        
        if !judgeValue() {
            return
        }
        guard let coinTypeCell:ChooseCoinTypeCell = self.typeCell,//tab.cellForRow(at: IndexPath(row: 0, section: 0)) as? ChooseCoinTypeCell,
            let addressCell:WatchInputContentCell = self.addressCell,
            let walletNameCell:InputWalletNameCell = self.nameCell,
            let typeStr = coinTypeCell.typeName.titleLabel?.text,
            let coinType = CoinType.init(rawValue: typeStr)
//            let pwdCell:SetWalletPassword = self.pwCell
            else {
                return
        }
        
        let address = addressCell.textView.text.replacingOccurrences(of: " ", with: "")
        let result = SwiftWalletManager.shared.createWalletByAddress(address: address, walletName: walletNameCell.walletName.text, coinType: coinType)
        
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
            
        }else {
            
            if result.error.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                self.noticeOnlyText(result.error)
            }
            
            if result.2 {
                //存储失败，删除，需要重新创建
                SwiftWalletManager.shared.walletArr.removeLast()
                
                createWalletFailed()
            }
        }
    }
    private func createWalletFailed() {
//        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Import_failure_Prompt)
        self.noticeOnlyText(SWLocalizedString(key: "no_wallet"))
    }
    
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
        guard let kCell = self.addressCell,
//            let pCell = self.pwCell,
            let nCell = self.nameCell,
            let aCell = self.agreeCell,
//            let pField = pCell.passwordTF,
//            let paField = pCell.confirmPwdTF,
            let kField = kCell.textView,
            let nField = nCell.walletName,
            let aBtn = aCell.selectBtn else {
                return
        }
//        let pArr = [pField, paField]
        let nArr = [kField, nField]
//        for object in pArr {
//            if object == field {
//                if length < 8 {
//                    self.enableSubmitBtn(enable: false)
//                    return
//                }
//            } else {
//                if object.text!.count < 8 {
//                    self.enableSubmitBtn(enable: false)
//                    return
//                }
//            }
//        }
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
        return 4
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 4 ? errorTipH : 16
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headV = (section == 3) ? CreateWalletErrorTipsView() : UIView()
        if section == 3 {
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
            let cell:WatchInputContentCell = tableView.dequeueReusableCell(withIdentifier: "WatchInputContentCell") as! WatchInputContentCell
            cell.textView.placeholder = SWLocalizedString(key: "watch_wallet_import_hint")
            self.addressCell = cell
            return cell
        case 2:
            let cell:InputWalletNameCell = tableView.dequeueReusableCell(withIdentifier: "InputWalletNameCell") as! InputWalletNameCell
            self.nameCell = cell
            return cell
//        case 3:
//            let cell:SetWalletPassword = tableView.dequeueReusableCell(withIdentifier: "SetWalletPassword") as! SetWalletPassword
//            self.pwCell = cell
//            return cell
        case 3:
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
	
	@objc private func back(){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_WatchWallet_Page)
		self.navigationController?.popViewController(animated: true)
	}
    
    @objc private func scan(){
        self.view.endEditing(true)
        let scanVC = ScanViewController()
        scanVC.completeBlock = {(scanStr) -> () in
            scanVC.dismiss(animated: true, completion: {
                self.scanString = scanStr
            })
        }
        self.present(scanVC, animated: true, completion: nil)
    }
    
    @objc private func tap(gesture:UITapGestureRecognizer){
        UIApplication.shared.keyWindow?.endEditing(false)
    }
    
}
