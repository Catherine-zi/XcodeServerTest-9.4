//
//  TransferAccountsViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/3/27.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD
import EthereumKit

class TransferAccountsViewController: UIViewController {
    
    var walletModel: SwiftWalletModel?
    var assetType: AssetsTokensModel?
    var destinationAddress: String?
    var btcFee: SwiftTransaction.BTCFeeRate = .normal
    var ethFee: String = "" {
        didSet {
            self.ethFeeLbl.text = ethFee
            if walletModel?.coinType != nil {
                self.advanceFeeLbl.text = SWLocalizedString(key: "mining_fee") + " = " + ethFee + (walletModel?.coinType)!.rawValue
            }
        }
    }
    var ethGasModel: EthGasInfoModel? {
        didSet {
            self.configureGas()
        }
    }
    var ethGasMin: Decimal = 0.0
    var ethGasMax: Decimal = 0.0
    var ethGasDefault: Decimal = 0.0
    
    var isAdvance = false
    
//    var scanView: UIView?
    @IBOutlet weak var miningTitleLabel: UILabel!
    @IBOutlet weak var slowTitleLabel: UILabel!
    @IBOutlet weak var fastTitleLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var miningFeeView: UIView!
    @IBOutlet weak var normalSwitchBtn: UIButton!
    
    
    @IBOutlet var advanceView: UIView!
    @IBOutlet var advanceMiningLabel: UILabel!
    @IBOutlet var advance2Label: UILabel!

    @IBOutlet weak var advanceGasPriceField: UITextField!
    @IBOutlet weak var advanceGasField: UITextField!
    @IBOutlet weak var advanceHexField: SWPlaceholderTextView!
    @IBOutlet weak var advanceFeeLbl: UILabel!
    @IBOutlet weak var advanceSwitchLbl: UILabel!
    @IBOutlet weak var advanceSwitchBtn: UIButton!
    @IBOutlet weak var ethFeeLbl: UILabel!
    @IBOutlet weak var ethUnitLbl: UILabel!
    @IBOutlet weak var feeSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_SendDetail_Page)

        // Do any additional setup after loading the view.
        if self.walletModel == nil {
            self.walletModel = SwiftWalletManager.shared.selectedAssetWallet
        }
        if self.walletModel != nil {
            if self.walletModel!.coinType == CoinType.ETH && self.assetType == nil {
                if self.walletModel!.assetsType != nil {
                    if self.walletModel!.assetsType!.count > 0 {
                        self.assetType = self.walletModel!.assetsType![0]
                    }
                }
            }
        }
        
        self.setUpViews()
        self.setUpNavigationUI()
        if self.walletModel?.coinType == CoinType.ETH {
            self.requestGas()
        }
		NotificationCenter.default.addObserver(self, selector: #selector(backButtonClick(_:)), name: SWNotificationName.dismissTransactionVc.notificationName, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.walletModel?.coinType == CoinType.ETH {
            self.advanceView.frame = CGRect.init(origin: self.miningFeeView.frame.origin, size: self.advanceView.frame.size)
        }
//        else if self.walletModel!.coinType == CoinType.BTC {
//            self.miningFeeView.frame = CGRect.init(origin: self.miningFeeView.frame.origin, size: self.miningFeeView.frame.size)
//        }
    }
    
    private func setUpViews() {
    
        miningTitleLabel.text = SWLocalizedString(key: "mining_fee")
        advanceMiningLabel.text = SWLocalizedString(key: "mining_fee")
        advance2Label.text = SWLocalizedString(key: "advance")
        advanceSwitchLbl.text = SWLocalizedString(key: "advance")
        slowTitleLabel.text = SWLocalizedString(key: "slow")
        fastTitleLabel.text = SWLocalizedString(key: "fast")
        nextBtn.setTitle(SWLocalizedString(key: "next"), for: .normal)
        
        addressTextField.placeholder = SWLocalizedString(key: "receiver_address")
        amountTextField.placeholder = SWLocalizedString(key: "amount")

        advanceGasField.placeholder = SWLocalizedString(key: "custom_gas")
        advanceGasPriceField.placeholder = SWLocalizedString(key: "gas_price_hint")
        advanceHexField.placeholder = SWLocalizedString(key: "hexadecimal_data")
        
        self.feeSlider.setThumbImage(#imageLiteral(resourceName: "TransferAccounts_slide"), for: .normal)
//        self.normalSwitch.onImage = #imageLiteral(resourceName: "addAssets_open")
//        self.normalSwitch.offImage = #imageLiteral(resourceName: "addAssets_close")
    
        if self.walletModel?.coinType == CoinType.BTC {
            self.titleLbl.text = "BTC"
        } else if self.walletModel?.coinType == CoinType.ETH {
            if self.assetType != nil {
                self.titleLbl.text = self.assetType!.symbol
            } else {
                self.titleLbl.text = "ETH"
            }
        }
        if self.destinationAddress != nil {
            self.addressTextField.text = self.destinationAddress!
        }

        self.addressTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.amountTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        if self.walletModel?.coinType == CoinType.ETH {
//            self.memoView.isHidden = true
//            self.momoTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
//            self.normalSwitch.isOn = false
            self.advanceView.isHidden = true
            self.view.addSubview(self.advanceView)
            self.advanceView.snp.makeConstraints { (make) in
                make.top.left.right.equalTo(self.miningFeeView)
                make.height.equalTo(267)
            }
            let gasInfo = UserDefaults.standard.data(forKey: "ethGasInfoKey")
            if gasInfo != nil {
                self.ethGasModel = try? JSONDecoder().decode(EthGasInfoModel.self, from: gasInfo!)
            }
        } else if self.walletModel?.coinType == CoinType.BTC {
//            self.memoView.isHidden = true
//            self.normalSwitch.isHidden = true
            self.advanceSwitchLbl.isHidden = true
            self.ethFeeLbl.isHidden = true
            self.ethUnitLbl.isHidden = true
        }
		self.getGasFromSlider()
    }
    
    private func requestGas() {
        EthAPIProvider.request(EthAPI.ethGasInfo()) { [weak self](result) in
            switch result {
            case let .success(response):
                guard let json = try? JSONDecoder().decode(EthGasInfoModel.self, from: response.data) else {
                    return
                }
                print(json)
                UserDefaults.standard.set(response.data, forKey: "ethGasInfoKey")
                self?.ethGasModel = json
            case let .failure(error):
                print("get gas info error:\n\(error)")
            }
        }
    }
    
    private func configureGas() {
        
        if self.ethGasModel == nil {
            let min: Decimal = 0.000000001
            let max: Decimal = 0.0000001
            self.configureGasStep2(min: min, max: max)
            return
        }
        
        guard let averageStr = self.ethGasModel!.average,
            let avarageInt = Int(averageStr),
            let fastStr = self.ethGasModel!.fast,
            let fastInt = Int(fastStr),
            let minInWei = try? Converter.toWei(GWei: avarageInt / 10),
            let defaultInWei = try? Converter.toWei(GWei: fastInt / 10),
            let maxInWei = try? Converter.toWei(GWei: 100),
            let ethGasMinUnit = try? Converter.toEther(wei: Wei(minInWei)),
            let ethGasMaxUnit = try? Converter.toEther(wei: Wei(maxInWei))
        else {
            let min: Decimal = 0.000000001
            let max: Decimal = 0.0000001
            self.configureGasStep2(min: min, max: max)
            return
        }
        
        self.configureGasStep2(min: ethGasMinUnit, max: ethGasMaxUnit)
        
    }
    
    private func configureGasStep2(min: Decimal, max: Decimal) {
        
        self.ethGasMin = min * 21000
        self.ethGasMax = max * 21000
        //        self.ethGasDefault = (try! Converter.toEther(wei: Wei(defaultInWei))) * 21000
        self.ethGasDefault = 0.00021
        self.feeSlider.value = (((self.ethGasDefault - self.ethGasMin) / (self.ethGasMax - self.ethGasMin)) as NSNumber).floatValue
        self.getGasFromSlider()
    }

//    @IBAction func normalSwitchTapped(_ sender: Any) {
//        SPUserEventsManager.shared.trackEventAction(SWUEC_Advanced_Status, eventPrame: "1")
//        self.miningFeeView.isHidden = true
//        self.advanceView.isHidden = false
//        self.normalSwitch.isOn = false
//        self.calculateGas()
//        self.isAdvance = true
//    }
//    @IBAction func advanceSwitchTapped(_ sender: Any) {
//        SPUserEventsManager.shared.trackEventAction(SWUEC_Advanced_Status, eventPrame: "0")
//        self.miningFeeView.isHidden = false
//        self.advanceView.isHidden = true
//        self.advanceSwitch.isOn = true
//        self.getGasFromSlider()
//        self.isAdvance = false
//    }
    @IBAction func feeSliderChanged(_ sender: Any) {
        if self.walletModel?.coinType == CoinType.BTC {
            if self.feeSlider.value <= 0.25 {
                self.feeSlider.value = 0
                self.btcFee = SwiftTransaction.BTCFeeRate.slow
            } else if self.feeSlider.value <= 0.75 {
                self.feeSlider.value = 0.5
                self.btcFee = SwiftTransaction.BTCFeeRate.normal
            } else {
                self.feeSlider.value = 1
                self.btcFee = SwiftTransaction.BTCFeeRate.fast
            }
        } else if self.walletModel?.coinType == CoinType.ETH {
            self.getGasFromSlider()
        }
    }
    @IBAction func gasPriceEditted(_ sender: Any) {
        print(self.advanceGasPriceField.text ?? "error")
        self.calculateGas()
    }
    @IBAction func gasEditted(_ sender: Any) {
        print(self.advanceGasField.text ?? "error")
        self.calculateGas()
    }
    
    private func getGasFromSlider() {
        let fee: Decimal = self.ethGasMin + (Decimal(Double(self.feeSlider.value)) * (self.ethGasMax - self.ethGasMin))
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 8;
        guard let priceString = currencyFormatter.string(from: fee as NSNumber)
        else {
            return
        }
        self.ethFee = priceString
    }
    
    private func calculateGas() {
        guard let gasStr = self.advanceGasField.text,
            let gas = Decimal(string: gasStr),
            let gasPriceStr = self.advanceGasPriceField.text,
            let gasPrice = Decimal(string: gasPriceStr)
        else {
            self.ethFee = ""
            return
        }
        let feeInEther = gas * gasPrice / 1000000000
        self.ethFee = feeInEther.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
//
//        self.navigationController?.navigationBar.shadowImage = UIImage.init()
    }
    func setUpNavigationUI()  {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_SendDetail_Page)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func scanButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Scan_SendDetail_Page)
        let scanVC = ScanViewController()
        scanVC.completeBlock = {(scanStr) -> () in
            scanVC.dismiss(animated: true, completion: {
                self.addressTextField.text = scanStr
            })
        }
        self.present(scanVC, animated: true, completion: nil)
//        if self.scanView == nil {
//            weak var weakSelf = self
//            self.scanView = UIView.init(frame: self.view.bounds)
//            if let scan = BTCQRCode.scannerView({ (address) in
//                if let address = address {
//                    weakSelf?.dealScanView(scanText: address)
//                }
//            }) {
//                if let frame = weakSelf?.view.bounds {
//                    scan.frame = frame
//                    scanView?.addSubview(scan)
//                }
//            }
//
//            if let height = weakSelf?.view.frame.height {
//                let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: height - 50, width: (weakSelf?.view.frame.width)!, height: 50))
//                closeBtn.setTitle("Close", for: .normal)
//                closeBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "1e59f5")), for: .normal)
//                closeBtn.addTarget(weakSelf, action: #selector(dismissScanView), for: .touchUpInside)
//                scanView?.addSubview(closeBtn)
//            }
//        }
//        self.view.addSubview(scanView!)
    }
//    private func dealScanView(scanText: String) {
//        self.dismissScanView()
//        self.addressTextField.text = scanText
//    }
//    @objc private func dismissScanView() {
//        self.scanView?.removeFromSuperview()
//    }
    
    
    @IBAction func normalSwitchTapped(_ sender: UIButton) {
        SPUserEventsManager.shared.trackEventAction(SWUEC_Advanced_Status, eventPrame: "1")
        self.miningFeeView.isHidden = true
        self.advanceView.isHidden = false
        self.calculateGas()
        self.isAdvance = true
    }
    
    @IBAction func advanceSwitchTapped(_ sender: UIButton) {
        SPUserEventsManager.shared.trackEventAction(SWUEC_Advanced_Status, eventPrame: "0")
        self.miningFeeView.isHidden = false
        self.advanceView.isHidden = true
        self.getGasFromSlider()
        self.isAdvance = false
    }
    
    @IBAction func nextButtonClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Next_SendDetail_Page)
        if self.walletModel == nil {
            self.noticeOnlyText(SWLocalizedString(key: "network_error"))
            return
        }
        
        if self.assetType?.balance == nil {
            self.noticeOnlyText(SWLocalizedString(key: "network_error"))
            return
        }
        if self.amountTextField.text == nil {
            self.noticeOnlyText(SWLocalizedString(key: "invalid_amount"))
            return
        }
        if self.addressTextField.text == nil {
            self.noticeOnlyText(SWLocalizedString(key: "address_not_valid"))
            return
        }
        if self.addressTextField.text == self.walletModel!.extendedPublicKey {
            self.noticeOnlyText(SWLocalizedString(key: "address_self"))
            return
        }
        guard let amountStr = self.amountTextField.text,
            let amount = Decimal(string: amountStr) else {
            self.noticeOnlyText(SWLocalizedString(key: "invalid_amount"))
            return
        }
        if amount > self.assetType!.balance! {
            self.noticeOnlyText(SWLocalizedString(key: "insufficient_balance"))
            return
        }
        if amount == 0 {
            self.noticeOnlyText(SWLocalizedString(key: "invalid_amount"))
            return
        }
        if self.walletModel!.coinType == CoinType.ETH && self.ethFee == "" {
            self.noticeOnlyText(SWLocalizedString(key: "invalid_amount"))
            return
        }
        if self.advanceHexField.text != nil && self.advanceHexField.text!.count > 0 && self.advanceHexField.text! != SWLocalizedString(key: "hexadecimal_data") {
            let hexSet = CharacterSet.init(charactersIn: "0123456789abcdefABCDEF").inverted
            let range = self.advanceHexField.text.rangeOfCharacter(from: hexSet)
            if (range != nil) {
                self.noticeOnlyText(SWLocalizedString(key: "invalid_data"))
                return
            }
        }
        
        if self.compareLastReceiver(currentReceiver: self.addressTextField.text!) {
            self.goConfirm()
        } else {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_TransferAgain_Warning_Popup)
            let backView = UIView.init(frame: self.view.bounds)
            backView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            let duplicateView = ConfirmDuplicateSendView()//.init(frame: CGRect.init(x: 0.5 * (self.view.frame.size.width - 330), y: 0.5 * (self.view.frame.size.height - 220), width: 330, height: 220))
            backView.addSubview(duplicateView)
            duplicateView.snp.makeConstraints { (make) in
                make.centerY.equalTo(backView)
                make.centerX.equalTo(backView)
                make.left.equalTo(20)
            }
            duplicateView.excuteBlock = {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Yes_TransferAgain_Warning_Popup)
                backView.removeFromSuperview()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_TransferAgain_Warning_Popup)
                self.goConfirm()
            }
            duplicateView.cancelBlock = {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_No_TransferAgain_Warning_Popup)
                backView.removeFromSuperview()
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_TransferAgain_Warning_Popup)
            }
            self.view.addSubview(backView)
        }
    }
    
    private func goConfirm() {
        var inputModel = TransactionInputModel()
        guard let addressStr = self.addressTextField.text,
            let amountStr = self.amountTextField.text
        else {
            return
        }
        inputModel.address = addressStr
        inputModel.amount = amountStr
        if self.walletModel?.coinType == CoinType.BTC {
            if !SwiftWalletManager.shared.validateBtcAddress(address: addressStr) {
                self.noticeOnlyText(SWLocalizedString(key: "address_not_valid"))
                return
            }
            inputModel.btcFee = self.btcFee
            inputModel.unit = "BTC"
        } else {
            if !SwiftWalletManager.shared.validateEthAddress(address: addressStr) {
                self.noticeOnlyText(SWLocalizedString(key: "address_not_valid"))
                return
            }
            inputModel.assetModel = self.assetType
            inputModel.ethFee = self.ethFee
            inputModel.unit = self.assetType?.symbol
            if (self.isAdvance) {
                
                guard let gasPriceStr = self.advanceGasPriceField.text,
                    let gasPriceDecim = Decimal(string: gasPriceStr),
                    let gasLimitStr = self.advanceGasField.text,
                    let gasLimitDecim = Decimal(string: gasLimitStr)
                else {
                        return
                }
                if gasPriceDecim < 0 {
                    self.noticeOnlyText(SWLocalizedString(key: "gas_price_toast"))
                    return
                }
                if gasLimitDecim < 21000 {
                    self.noticeOnlyText(SWLocalizedString(key: "gas_toast"))
                    return
                }
                
                inputModel.ethGasPrice = (gasPriceDecim * 1000000000).description
                inputModel.ethGasLimit = self.advanceGasField.text
                if self.advanceHexField.text.count > 0 {

                    inputModel.data = OCLanguage.swdata(fromHex: self.advanceHexField.text)//BTCDataFromHex(self.advanceHexField.text) //Data.init(hex: self.advanceHexField.text)

                }
            } else {
                if self.assetType?.symbol == "ETH" {
                    inputModel.ethGasLimit = "30000"
                } else {
                    inputModel.ethGasLimit = assetType?.gas
                }
//                let str = (Decimal(string:self.ethFee)! / 21000 * 1000000000000000000).description
                guard let gasPriceDecim = Decimal(string:self.ethFee) else {
                    return
                }
                inputModel.ethGasPrice = SwiftExchanger.shared.getWei(from: (gasPriceDecim / 21000).description)?.description//String(str.split(separator: ".").first!)
//                do {
//                    inputModel.ethGasPrice = try Converter.toWei(ether: (Decimal(string:self.ethFee)! / 21000)).description
//                } catch {
//                    print(error)
//                }
            }
        }
        
        let sendDetailVC = SendDetailViewController.init(nibName: "SendDetailViewController", bundle: nil)
        sendDetailVC.walletModel = self.walletModel!
        sendDetailVC.inputModel = inputModel
        sendDetailVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        sendDetailVC.modalPresentationStyle = .custom
        
        self.present(sendDetailVC, animated: false, completion: nil)
    }
    
    private func compareLastReceiver(currentReceiver address: String) -> Bool {
        var symbol = ""
        if self.walletModel?.coinType == CoinType.BTC {
            symbol = "BTC"
        } else if self.walletModel?.coinType == CoinType.ETH {
            symbol = self.assetType?.symbol ?? "UNKNOW"
        }
        guard let receiverData = UserDefaults.standard.dictionary(forKey: symbol + "LastReceiverKey") else {
            return true
        }
        guard let oldAddress: String = receiverData["receiver"] as? String else {
            return true
        }
        if address != oldAddress {
            return true
        }
        guard let intervalStr: String = receiverData["time"] as? String else {
            return true
        }
        guard let oldTime = TimeInterval(intervalStr) else {
            return true
        }
        let interval = (Date.init().timeIntervalSince1970) - oldTime
        if interval > 300 {
            return true
        }
        return false
    }
    
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        self.addressTextField.resignFirstResponder()
        self.amountTextField.resignFirstResponder()
    
    }
    
    struct TransactionInputModel:Codable {
        var amount: String?
        var address: String?
        var data: Data?
        var ethFee: String?
        var ethGasPrice: String?
        var ethGasLimit: String?
        var btcFee: SwiftTransaction.BTCFeeRate?
        var assetModel: AssetsTokensModel?
        var unit: String?
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}


