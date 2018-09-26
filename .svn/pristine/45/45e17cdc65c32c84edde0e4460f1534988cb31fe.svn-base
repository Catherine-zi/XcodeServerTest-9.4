//
//  WalletDetailViewController.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/7.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit
import PKHUD

private enum FunctionType: String {
    case CopyAddress = "CopyAddress"
    case SetBoughtPrice = "SetBoughtPrice"
    case ChangeName = "ChangeName"
    case ChangePassword = "ChangePassword"
    case Backup = "Backup"
    case ExportKey = "ExportKey"
    case ExportKeystore = "ExportKeystore"
}

class WalletDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var backImgView: UIImageView!
//    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var backImg:UIImage?
    var walletModel:SwiftWalletModel? = nil
//    var balance:String = "--"
//    var address:String = ""
    let transactionManager = SwiftTransaction()
    
    private var dataArr:[[[String:String]]] = [[[:]]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadTableData), name: SWNotificationName.costPriceChange.notificationName, object: nil)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WalletsCards_page)
        setUpViews();
    }

    private func setUpViews() {
        
        if self.walletModel == nil {
            return
        }
        
        self.navTitleLabel.text = SWLocalizedString(key: "wallet_detail")
        self.deleteBtn.setTitle(SWLocalizedString(key: "delete_wallet"), for: .normal)
//        if self.walletModel?.coinType == CoinType.ETH {
//            self.loadEthCurrencyAndAddress()
//        } else if self.walletModel?.coinType == CoinType.BTC {
//            self.loadBtcCurrency()
//        }
        
        if self.backImg != nil {
            self.backImgView.image = self.backImg!
        } else {
            if let back = self.walletModel?.backgroundColor {
                self.backImgView.image = UIImage.init(named: back)
            }
        }
        self.headerReload()
        self.nameLbl.text = self.walletModel?.walletName
        self.addressLbl.text = self.walletModel?.extendedPublicKey
//        self.unitLbl.text = (self.walletModel?.coinType)?.rawValue
//        if walletModel?.walletImage != nil {
//            self.iconImgView.image = UIImage.init(named: self.walletModel!.walletImage!)
//        }
        
        self.tableView.backgroundColor = UIColor.init(white: 242.0/255, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(WalletDetailCell.classForCoder(), forCellReuseIdentifier: "walletDetailCell")
        let footer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        footer.backgroundColor = self.tableView.backgroundColor
        self.tableView.tableFooterView = footer
        
        loadTableData()
    }
    
    @objc private func loadTableData() {
        
        if let wallet = self.walletModel {
            let cost = SwiftExchanger.shared.calculateTotalCost(wallet: wallet)
            let costStr = SwiftExchanger.shared.currencySymbol + SwiftExchanger.shared.getRoundedNumberString(numberString: cost.description, decimalCount: 2)
        
            dataArr = [
                [["title":SWLocalizedString(key: "wallet_copy_address"),"accType":"arrow",
                  "function":FunctionType.CopyAddress.rawValue]],
                [["title":SWLocalizedString(key: "set_bought_price"),"accType":"both",
                  "accText":costStr,
                  "function":FunctionType.SetBoughtPrice.rawValue]],
                [["title":SWLocalizedString(key: "edit_wallet_name"),
                  "accType":"text","accText":self.walletModel!.walletName ?? "",
                  "function":FunctionType.ChangeName.rawValue]]
            ]
            
            // watch or not
            if self.walletModel?.extendedPrivateKey != nil,
                self.walletModel?.password != nil {
            
                var cellArr = [["title":SWLocalizedString(key: "change_password"),
                                "accType":"arrow",
                                "function":FunctionType.ChangePassword.rawValue],
                               ["title":SWLocalizedString(key: "export_private_key"),
                                "accType":"arrow",
                                "function":FunctionType.ExportKey.rawValue]]
                
                //        if (self.walletModel?.coinType == CoinType.ETH) {
                //            cellArr.append(["title":SWLocalizedString(key: "export_keystore"),"accType":"arrow","function":FunctionType.ExportKeystore.rawValue])
                //        }
                if self.walletModel?.isBackUp != nil {
                    if (!self.walletModel!.isBackUp!) {
                        cellArr.append(["title":SWLocalizedString(key: "export_mnemonic"),"accType":"arrow","function":FunctionType.Backup.rawValue])
                    }
                }
                dataArr.append(cellArr)
            }
            self.tableView.reloadData()
        }
    }
    
    func headerReload() {
        var balanceStr = "0.0"
        if let decim = self.walletModel?.totalAssets {
            if decim < 10000000000 {
                balanceStr = String(decim.description.prefix(10))
            } else {
                balanceStr = decim.description
            }
        }
        self.balanceLbl.text = SwiftExchanger.shared.currencySymbol + balanceStr
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView();
        header.backgroundColor = tableView.backgroundColor
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WalletDetailCell = tableView.dequeueReusableCell(withIdentifier: "walletDetailCell", for: indexPath) as! WalletDetailCell
        if dataArr[indexPath.section].count == 1 {
            cell.configureType(type: WalletDetailCell.WalletDetailCellPositionType.WalletDetailCellPositionAlone)
        } else if indexPath.row == 0 {
            cell.configureType(type: WalletDetailCell.WalletDetailCellPositionType.WalletDetailCellPositionTop)
        } else if indexPath.row == dataArr[indexPath.section].count - 1 {
            cell.configureType(type: WalletDetailCell.WalletDetailCellPositionType.WalletDetailCellPositionBottom)
        } else {
            cell.configureType(type: WalletDetailCell.WalletDetailCellPositionType.WalletDetailCellPositionMiddle)
        }
        cell.configureContent(data: dataArr[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//
//        } else {
            guard let function = self.dataArr[indexPath.section][indexPath.row]["function"],
            let type = FunctionType(rawValue: function) else {
                return
            }
            switch type {
            case FunctionType.ChangePassword:
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ChangePassword)
                self.changePassword()
            case FunctionType.Backup:
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_BackupWallet)
//                SWUEC_Click_Backup_WalletsCards_page
                self.backupWallet()
            case .ExportKey:
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ExportPrivateKey)
                self.exportPrivateKey()
            case .ExportKeystore:
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ExportKeystore)
                break
            case .ChangeName:
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_EditWalletName)
                self.showNameModifyAlert()
            case .CopyAddress:
                self.goCopyAddress()
//                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CopyAddress_WalletsCards_page)
//                let paste = UIPasteboard.general
//                paste.string = self.walletModel?.extendedPublicKey
//                self.noticeOnlyText(SWLocalizedString(key: "copy_success"))
            case .SetBoughtPrice:
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_SetTotalCost)
                let setVC = TotalCostViewController()
                setVC.walletModel = self.walletModel
                self.navigationController?.pushViewController(setVC, animated: true)
        }
//        }
    }
    
    func showNameModifyAlert() {
        let alertController = UIAlertController(title: SWLocalizedString(key: "edit_wallet_name"), message: SWLocalizedString(key: "new_wallet_name"), preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: SWLocalizedString(key: "wallet_confirm"), style: .default) { (_) in
            let name = alertController.textFields?[0].text
            if let count = name?.count {
                if count > 0 {
                    self.walletModel?.walletName = name
                    let isSuccess = SwiftWalletManager.shared.modifyName(privateKeyHash: self.walletModel!.extendedPrivateKey!, name: name!)
                    if isSuccess {
                        self.loadTableData()
                        self.tableView.reloadData()
                        self.noticeOnlyText(SWLocalizedString(key: "wallet_name_edit_success"))
                    } else {
                        self.noticeOnlyText(SWLocalizedString(key: "unknown_error"))
                    }
                } else {
                    self.noticeOnlyText(SWLocalizedString(key: "wallet_name_empty"))
                }
            }
        }
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), style: .cancel) { (_) in }

        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = SWLocalizedString(key: "new_wallet_name")
            textField.text = self.walletModel?.walletName
        }

        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changePassword() {
        let changeVc = ChangePasswordViewController()
        changeVc.walletModel = self.walletModel
        self.navigationController?.pushViewController(changeVc, animated: true)
    }
    
    func exportPrivateKey() {
        
        let verifyView = Bundle.main.loadNibNamed("BackUpVerifyPwdView", owner: nil, options: nil)?.first as! BackUpVerifyPwdView
        verifyView.frame = VisualEffectView.subFrame
        let visualView = VisualEffectView.visualEffectView(frame:view.bounds)
        visualView.contentView.addSubview(verifyView)
        view.addSubview(visualView)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WalletPassword_Popup)
        
        verifyView.deleteWalletBlock = {[weak self,weak visualView] in
            if self?.walletModel?.extendedPrivateKey != nil {
                SwiftNotificationManager.shared.removeNotification(wallet: self!.walletModel!, registrationId: nil)
                let suc = SwiftWalletManager.shared.removeWallet(privateKeyHash: (self?.walletModel?.extendedPrivateKey)!)
                if suc {
                    visualView?.removeFromSuperview()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        verifyView.cancelBlock = { [weak visualView] in
            visualView?.removeFromSuperview()
        }
        verifyView.confirmBlock = {[weak self,weak visualView] (pwd:String) in
            guard let password = self?.walletModel?.password else {
                return false
            }
            if pwd == SwiftWalletManager.shared.normalDecrypt(string: password) {
                
                verifyView.removeFromSuperview()
                visualView?.isUserInteractionEnabled = true
                visualView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self?.dismissKeyView(recognizer:))))
                let keyView = ExportPrivateKeyView()
                if let encryptPrivateKey = self?.walletModel?.extendedPrivateKey,
                    let privateKey = SwiftWalletManager.shared.customDecrypt(string: encryptPrivateKey, key: pwd)
                {
                    keyView.key = privateKey
                    visualView?.contentView.addSubview(keyView)
                    keyView.snp.makeConstraints({ (make) in
                        make.centerX.equalTo(visualView!)
                        make.centerY.equalTo(visualView!)
                        make.left.equalTo(20)
                    })
//                    keyView.frame = CGRect.init(x: 20, y: 0.5 * ((self?.view.frame.size.height)! - 330), width: (self?.view.frame.size.width)! - 40, height: 330)
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_ExportPrivateKey_Popup)
                    
                    return true
                }
            }
            return false
        }
        verifyView.pwdInput.becomeFirstResponder()
        
//        let pwView = ConfirmPwdView()
//        pwView.setWarnText(text: SWLocalizedString(key: "input_password_alert"))
//        pwView.setWarnAgainText(text: "")
//        let visualView = VisualEffectView.visualEffectView(frame:view.bounds)
//        visualView.isUserInteractionEnabled = true
//        visualView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyView(recognizer:))))
//
//        weak var weakSelf = self
//        func confirmTapped(pwd:String) -> Bool {
//            if pwd == self.walletModel?.password {
//                return true
//            } else {
//                return false
//            }
//        }
//        func cancelTapped() {
//            visualView.removeFromSuperview()
//        }
//        func excuteBlock() {
//            pwView.removeFromSuperview()
//            let keyView = ExportPrivateKeyView()
//            keyView.key = (weakSelf?.walletModel?.extendedPrivateKey)!
//            visualView.contentView.addSubview(keyView)
//            keyView.frame = CGRect.init(x: 0.5 * ((weakSelf?.view.frame.size.width)! - 330), y: 0.5 * ((weakSelf?.view.frame.size.height)! - 330), width: 330, height: 330)
//        }
//        pwView.cancelBlock = cancelTapped
//        pwView.confirmBlock = confirmTapped
//        pwView.excuteBlock = excuteBlock
//
//        visualView.contentView.addSubview(pwView)
//        pwView.frame = CGRect.init(x: 0.5 * (self.view.frame.size.width - 330), y: 0.5 * (self.view.frame.size.height - 280), width: 330, height: 280)
//        view.addSubview(visualView)
//        pwView.pwdInput.resignFirstResponder()
    }
    
    func backupWallet() {
        if self.walletModel == nil {
            return
        }
        let vc:BackUpWalletViewController = BackUpWalletViewController()
//        vc.mnemonic = self.walletModel?.mnemonic
//        vc.password = self.walletModel?.password
        vc.walletModel = self.walletModel!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissKeyView(recognizer:UITapGestureRecognizer) {
        if let views = recognizer.view?.subviews {
            for subView in views {
                if subView is ConfirmPwdView {
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_DeleteWallet_Popup)
                    break
                } else if subView is ExportPrivateKeyView {
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_ExportPrivateKey_Popup)
                }
            }
        }
        recognizer.view?.removeFromSuperview()
    }

    @IBAction func deleteTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_DeleteWallet)
        self.deleteWallet()
    }
    
    func deleteWallet() {
        var alertView: UIView?
        let visualView = VisualEffectView.visualEffectView(frame:view.bounds)
        visualView.isUserInteractionEnabled = true
        visualView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyView(recognizer:))))
        weak var weakSelf = self
        if self.walletModel?.extendedPrivateKey != nil {
            let deleteView = ConfirmPwdView()
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WalletPassword_Popup)
            
            func confirmTapped(pwd:String) -> Bool {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_DeleteWallet_Popup)
                guard let password = self.walletModel?.password else {
                    return false
                }
                if pwd == SwiftWalletManager.shared.normalDecrypt(string: password) {
                    return true
                } else {
                    return false
                }
            }
            func cancelTapped() {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Cancel_DeleteWallet_Popup)
                visualView.removeFromSuperview()
            }
            func excuteBlock() {
                guard let key = weakSelf?.walletModel?.extendedPrivateKey else {
                    return
                }
                if SwiftWalletManager.shared.removeWallet(privateKeyHash: key) {
                    SwiftNotificationManager.shared.removeNotification(wallet: self.walletModel!, registrationId: nil)
                    visualView.removeFromSuperview()
                    weakSelf?.navigationController?.popViewController(animated: true)
                    self.noticeOnlyText(SWLocalizedString(key: "delete_success"))
                    NotificationCenter.post(customeNotification: SWNotificationName.deleteWalletSuccess)
                }
            }
            deleteView.cancelBlock = cancelTapped
            deleteView.confirmBlock = confirmTapped
            deleteView.excuteBlock = excuteBlock
            alertView = deleteView
        } else {
            // watch
            let deleteView = ConfirmDuplicateSendView()
            deleteView.warnAgainLbl.text = SWLocalizedString(key: "delete_wallet")
            deleteView.excuteBlock = {
                guard let address = weakSelf?.walletModel?.extendedPublicKey else {
                    return
                }
                if SwiftWalletManager.shared.removeWallet(address: address) {
                    SwiftNotificationManager.shared.removeNotification(wallet: self.walletModel!, registrationId: nil)
                    visualView.removeFromSuperview()
                    weakSelf?.navigationController?.popViewController(animated: true)
                    self.noticeOnlyText(SWLocalizedString(key: "delete_success"))
                    NotificationCenter.post(customeNotification: SWNotificationName.deleteWalletSuccess)
                }
            }
            deleteView.cancelBlock = {
                visualView.removeFromSuperview()
            }
            alertView = deleteView
        }
        
        guard let aView = alertView else {
            return
        }
        visualView.contentView.addSubview(aView)
        aView.snp.makeConstraints { (make) in
            make.centerY.equalTo(visualView)
            make.centerX.equalTo(visualView)
            make.left.equalTo(20)
        }
        view.addSubview(visualView)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_DeleteWallet_Popup)
    }
    
    private func goCopyAddress() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CopyAddress_WalletsCards_page)
        let createWalletVC = GenerateQRCodeViewController.init(nibName: "GenerateQRCodeViewController", bundle: nil)
        createWalletVC.view.backgroundColor = UIColor.white.withAlphaComponent(0)
        //        createWalletVC.transitioningDelegate = self
        createWalletVC.modalPresentationStyle = .custom
        createWalletVC.walletAddress = self.walletModel!.extendedPublicKey!
        createWalletVC.receivingCodeLabel.text = self.walletModel!.walletName!
        createWalletVC.logoImageView.image = UIImage.init(named: self.walletModel!.walletImage!)
        self.present(createWalletVC, animated: true, completion: nil)
    }
    
    @IBAction func addressTapped(_ sender: UIButton) {
        self.goCopyAddress()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_WalletsCards_Page)
        self.navigationController?.popViewController(animated: true)
    }
    
}
