//
//  WalletPsdViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/27.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class WalletPswViewController: UIViewController {
    
    var walletModel: SwiftWalletModel?
    var inputModel: TransferAccountsViewController.TransactionInputModel?
	var transactionManager = SwiftTransaction()
	var transactionEnd = false
    var sendingImageView = UIImageView()
    var msgLabel = UILabel()
    //密码剩余错误次数
    var pwdRemainWrongNumber = 4

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var inputPwdLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var textFieldBgView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_WalletPassword_Send_Page)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        navTitleLabel.text = SWLocalizedString(key: "wallet_password")
        inputPwdLabel.text = SWLocalizedString(key: "input_password")
        textField.placeholder = SWLocalizedString(key: "input_password_alert")
        
        messageLabel.text = String(format: SWLocalizedString(key: "password_wrong"),pwdRemainWrongNumber)
        confirmButton.setTitle(SWLocalizedString(key: "wallet_confirm"), for: .normal)
        
        self.textField.layer.borderColor = UIColor.init(hexColor: "dddddd").cgColor
        self.textField.layer.borderWidth = 2
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
//        self.textField.layer.cornerRadius
        self.confirmButton.isEnabled = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {

//        self.navigationController?.popViewController(animated: true)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.dismiss(animated: false, completion: nil)
        self.dismiss(animated: false, completion: nil)
        NotificationCenter.post(customeNotification: SWNotificationName.dismissSendDetailVc)
        if self.transactionEnd {
            NotificationCenter.post(customeNotification: SWNotificationName.dismissTransactionVc)
        }
    }
    
    @IBAction func closeButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_WalletPassword_Send_Page)
//        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: !self.transactionEnd) {
            NotificationCenter.post(customeNotification: SWNotificationName.dismissSendDetailVc)
            if self.transactionEnd {
                NotificationCenter.post(customeNotification: SWNotificationName.dismissTransactionVc)
            }
        }
    }
    
    @IBAction func confirmButtonClick(_ sender: UIButton) {
        self.textField.resignFirstResponder()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_WalletPassword_Send_Page)
        
        if self.inputModel == nil || self.walletModel == nil {
            self.noticeOnlyText(SWLocalizedString(key: "network_error"))
            return
        }

        if let password = self.walletModel!.password {
            if  self.textField.text == SwiftWalletManager.shared.normalDecrypt(string: password) {
                self.checkPasswordCorrect()
            } else {
                self.checkPasswordError()
            }
        } else {
            self.checkPasswordError()
        }
    }
    //密码错误
    func checkPasswordError()  {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_WrongPassword_Prompt_Send_Page)
        self.textField.layer.borderColor = UIColor.init(hexColor: "F96C6C").cgColor
        self.textField.textColor = UIColor.init(hexColor: "F96C6C")
//        let errorMsg = "Wrong password, you have left 2 times! Or your wallet will be invalid."
//        self.messageLabel.text = errorMsg
        self.messageLabel.isHidden = false
        self.confirmButton.backgroundColor = UIColor.init(hexColor: "dddddd")
        self.confirmButton.isEnabled = false
    }
    //密码正确
    func checkPasswordCorrect()  {
        self.confirmButton.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "DCDCDC")), for: .normal)
        self.confirmButton.isEnabled = false
        self.transactionSending()
        self.sendTransaction()
    }
    
    private func transactionSent(success: Bool) {
        if !success {
            sendingImageView.image = UIImage.init(named: "TransferAccounts_sendFailed")
            msgLabel.text =  "Transaction Failure"
            self.closeButton.isHidden = false
        } else {
            sendingImageView.image = UIImage.init(named: "TransferAccounts_sendSuccess")
            msgLabel.text =  "Transaction Success"
            self.closeButton.isHidden = false
        }
    }
    
    private func transactionSending()  {
        
        for subView in bgView.subviews {
            if (subView.tag == 99) {
                subView.isHidden = true
            }
        }
		
		self.transactionEnd = true
        
        sendingImageView = UIImageView.init(image: UIImage.init(named: "TransferAccounts_sendSuccess"))
        let imageWidth: CGFloat = 80
        let imageHeight: CGFloat = 150
        let imageOrginY: CGFloat = 120

        sendingImageView.frame = CGRect.init(x: ( SWScreen_width-imageWidth)/2, y:imageOrginY , width: imageWidth, height: imageHeight)
        self.bgView.addSubview(sendingImageView)
        sendingImageView.alpha = 0
        
        let msgLabWidth: CGFloat = 180.0
        let msgLabHeight: CGFloat = 20.0
        msgLabel = UILabel.init()
        msgLabel.frame = CGRect.init(x: (SWScreen_width-msgLabWidth)/2, y: (imageOrginY+imageHeight+31), width: msgLabWidth, height: msgLabHeight)
        msgLabel.font = UIFont.systemFont(ofSize: 15)
        msgLabel.textAlignment = .center
        msgLabel.text = "Sending"
        self.bgView.addSubview(msgLabel)
        msgLabel.alpha = 0
        
        UIView.animate(withDuration: 1, animations: {
            self.navTitleLabel.text = SWLocalizedString(key: "send")
            self.sendingImageView.alpha = 1
            self.msgLabel.alpha = 1
            
        })
    }
    
    private func sendTransaction() {
        if let type = self.walletModel?.coinType {
            switch type {
            case .BTC:
                self.sendBtcTransaction()
            case .LTC:
                self.sendLtcTransaction()
            case .ETH:
                self.sendEthTransaction()
            }
        }
//        if self.walletModel!.coinType == CoinType.BTC {
//            self.sendBtcTransaction()
//        } else if self.walletModel!.coinType == CoinType.ETH {
//            self.sendEthTransaction()
//        }
    }
    
    private func sendBtcTransaction() {
        guard let encryptPrivateKey = self.walletModel!.extendedPrivateKey,
            let encryptPassword = self.walletModel!.password,
            let password = SwiftWalletManager.shared.normalDecrypt(string: encryptPassword),
            let privateKey = SwiftWalletManager.shared.customDecrypt(string: encryptPrivateKey, key: password),
            let destinationAddress = BTCPublicKeyAddress.init(string:self.inputModel!.address),
            let changeAddress = BTCPublicKeyAddress.init(string:self.walletModel!.extendedPublicKey),
            let amount = self.inputModel!.amount,
            let feeRate = self.inputModel!.btcFee
            else {
                self.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                self.transactionSent(success: false)
                return
        }
        
        self.transactionManager.createBtcTransaction(
            privateKey: privateKey,
            destinationAddress: destinationAddress,
            changeAddress: changeAddress,
            amount: amount,
            feeRate: feeRate,
            api: SwiftTransaction.BTCAPI.Testnet, completionHandler: self.processBtcTransaction(transaction:error:)
        )
    }
    
    private func sendLtcTransaction() {
        guard let encryptPrivateKey = self.walletModel!.extendedPrivateKey,
            let encryptPassword = self.walletModel!.password,
            let password = SwiftWalletManager.shared.normalDecrypt(string: encryptPassword),
            let privateKey = SwiftWalletManager.shared.customDecrypt(string: encryptPrivateKey, key: password),
            let destinationAddress = LTCPublicKeyAddress.init(string:self.inputModel!.address),
            let changeAddress = LTCPublicKeyAddress.init(string:self.walletModel!.extendedPublicKey),
            let amount = self.inputModel!.amount,
            let feeRate = self.inputModel!.ltcFee
            else {
                self.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                self.transactionSent(success: false)
                return
        }
        
        self.transactionManager.createLtcTransaction(
            privateKey: privateKey,
            destinationAddress: destinationAddress,
            changeAddress: changeAddress,
            amount: amount,
            feeRate: feeRate,
            completionHandler: self.processLtcTransaction(transaction:error:)
        )
    }
    
    private func sendEthTransaction() {
        guard let encryptPrivateKey = self.walletModel!.extendedPrivateKey,
            let encryptPassword = self.walletModel!.password,
            let password = SwiftWalletManager.shared.normalDecrypt(string: encryptPassword),
            let privateKey = SwiftWalletManager.shared.customDecrypt(string: encryptPrivateKey, key: password),
            let destinationAddress = self.inputModel!.address,
            let amount = self.inputModel!.amount,
            let ether = Decimal(string: amount),
            let assetModel = self.inputModel!.assetModel,
            let gasPriceStr = self.inputModel!.ethGasPrice,
            let gasLimitStr = self.inputModel!.ethGasLimit,
            let gasPriceDecim = Decimal(string: gasPriceStr),
            let gasLimitDecim = Decimal(string: gasLimitStr)
            else {
                self.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                self.transactionSent(success: false)
                return
        }
        
        let gasPrice = (gasPriceDecim as NSNumber).intValue
        let gasLimit = (gasLimitDecim as NSNumber).intValue
        self.transactionManager.createEthTransaction(
            privateKey: privateKey,
            destinationAddress: destinationAddress,
            assetModel: assetModel,
            ether: ether,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            data: self.inputModel!.data) { (tx, error) -> (Void) in
                let transaction = tx
                self.processEthTransaction(transaction: transaction, error: error)
        }
    }
    
    private func processBtcTransaction(transaction:BTCTransaction?, error:Error?) {
        if transaction == nil {
            self.noticeOnlyText(SWLocalizedString(key: "send_failed"))
            self.transactionSent(success: false)
            return
        }
        BtcAPIProvider.request(BtcAPI.btcSendRawTransaction(BTCHexFromData(transaction!.data))) { [weak self](result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(BtcRawTransactionModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "send transaction error")
                    self?.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                    self?.transactionSent(success: false)
                    return
                }
                let txid = json?.data.txid
                print(txid)
                self?.transactionSent(success: true)
                guard let address = self?.inputModel?.address else {
                    self?.transactionSent(success: false)
                    return
                }
                self?.saveLastReceiver(address: address)
            case let .failure(error):
                print("request error:\n\(error)")
//                self?.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.transactionSent(success: false)
            }
        }
    }
    
    private func processLtcTransaction(transaction:BTCTransaction?, error:Error?) {
        if transaction == nil {
            self.noticeOnlyText(SWLocalizedString(key: "send_failed"))
            self.transactionSent(success: false)
            return
        }
        LtcAPIProvider.request(LtcAPI.ltcSendRawTransaction(BTCHexFromData(transaction!.data))) { [weak self](result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(ltcRawTransactionModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "send transaction error")
                    self?.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                    self?.transactionSent(success: false)
                    return
                }
                let txid = json?.data.txid
                print(txid)
                self?.transactionSent(success: true)
                guard let address = self?.inputModel?.address else {
                    self?.transactionSent(success: false)
                    return
                }
                self?.saveLastReceiver(address: address)
            case let .failure(error):
                print("request error:\n\(error)")
                //                self?.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.transactionSent(success: false)
            }
        }
    }
    
    private func processEthTransaction(transaction:String?, error:Error?) {
        if transaction == nil {
            self.noticeOnlyText(SWLocalizedString(key: "send_failed"))
            self.transactionSent(success: false)
            return
        }
        EthAPIProvider.request(EthAPI.ethSendRawTransaction(transaction!), completion: { [weak self](result) in
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(EthSendTransactionModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "send transaction error")
                    self?.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                    self?.transactionSent(success: false)
                    return
                }
                self?.transactionSent(success: true)
                guard let address = self?.inputModel?.address else {
                    self?.transactionSent(success: false)
                    return
                }
                self?.saveLastReceiver(address: address)
            case let .failure(error):
                print("request error:\n\(error)")
//                self?.noticeOnlyText(SWLocalizedString(key: "send_failed"))
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.transactionSent(success: false)
            }
        })
    }
    
    private func saveLastReceiver(address: String) {
        var symbol = ""
        if self.walletModel?.coinType == CoinType.ETH {
            symbol = self.inputModel?.assetModel?.symbol ?? "UNKNOW"
        } else {
            symbol = self.walletModel?.coinType?.rawValue ?? "UNKNOW"
        }
        let receiverData = ["receiver": address,
                            "time": String(Date.init().timeIntervalSince1970)]
        UserDefaults.standard.set(receiverData, forKey: symbol + "LastReceiverKey")
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.textField.resignFirstResponder()
        if let str = self.textField.text {
            if str.count == 0 {
                self.textField.layer.borderColor = UIColor.init(hexColor: "dddddd").cgColor
            }
        }
    }
  
   
}

extension WalletPswViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (self.messageLabel.isHidden == false) {
            textField.text = ""
            self.textField.layer.borderColor = UIColor.init(hexColor: "1E59F5").cgColor
            self.textField.textColor = UIColor.init(hexColor: "1E59F5")//
            self.messageLabel.isHidden = true
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let length = textField.text!.count - range.length + string.count
        if length >= 8 {
            self.confirmButton.isEnabled = true
            self.confirmButton.backgroundColor = UIColor.init(hexColor: "1E59F5")
        } else {
            self.confirmButton.isEnabled = false
            self.confirmButton.backgroundColor = UIColor.init(hexColor: "dddddd")
        }
//        if (range.location == 0 && ((string.count) > 0)) {
//            self.textField.layer.borderColor = UIColor.init(hexColor: "1E59F5").cgColor
//            
//        } else if (range.location >= 7 && ((string.count) > 0)) {
//            self.confirmButton.isEnabled = true
//            self.confirmButton.backgroundColor = UIColor.init(hexColor: "1E59F5")
//        } else {
//            self.confirmButton.backgroundColor = UIColor.init(hexColor: "dddddd")
//            self.confirmButton.isEnabled = false
//        }
        return true

    }

}
