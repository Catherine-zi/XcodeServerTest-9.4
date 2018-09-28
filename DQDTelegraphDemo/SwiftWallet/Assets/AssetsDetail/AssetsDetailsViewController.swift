//
//  AssetsDetailsViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/9.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit

class AssetsDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AssetsDetailHeaderCollectionDelegate {
    
    
    var walletModel: SwiftWalletModel?
    private var btcPage: Int = 0 // get by offset from 0
    private var ethPage: Int = 1 // get by page from 1
    private var loading: Bool = false
    var assetIndexForInit: Int = 0 // for init only
    var selectedAsset: AssetsTokensModel? {
        didSet {
//            if !self.loading {
                reloadWalletData()
//            }
//            if self.walletModel!.coinType == CoinType.BTC {
//                self.reloadBtcData()
//            } else if self.walletModel!.coinType == CoinType.ETH {
//                self.reloadEthData()
//            }
        }
    }
    var transactionArr:[UniversalTransactionModel] = []
    
    var topCardView: AssetsDetailHeaderCardView?
    var topCollectionView: AssetsDetailHeaderCollectionView?
    
	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.transactionArr.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TransactionListCell = tableView.dequeueReusableCell(withIdentifier: "TransactionLogTabViewCell", for: indexPath) as! TransactionListCell
        let model = self.transactionArr[indexPath.row]
        cell.setContent(data: model)
        return cell
//        let cell:TransactionLogTabViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionLogTabViewCell") as! TransactionLogTabViewCell
//        cell.selectionStyle = .none
//        return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 8))
//        view.backgroundColor = tableView.backgroundColor
//        return view
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 8
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = TransactionDetailViewController()
        detailVC.type = self.walletModel?.coinType
        detailVC.transactionModel = self.transactionArr[indexPath.row]
        detailVC.walletModel = self.walletModel
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.transactionArr.count - 3) {
            if !self.loading {
                self.loadMoreData()
            }
        }
    }
    
    func assetsCollection(collectionView: AssetsDetailHeaderCollectionView, didSelectedWallet assetModel: AssetsTokensModel) {
        self.emptyView.isHidden = true
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ChangeCurrency_AssetsDetail_Page)
        
        self.transactionArr = []
        self.logTabView.reloadData()
        self.topCardView?.setContent(model: assetModel)
        self.selectedAsset = assetModel
    }
	
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var receiveBtn: UIButton!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewConsH: NSLayoutConstraint!
	@IBOutlet weak var logTabView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_AssetsDetail_Page)
        self.selectedAsset = self.walletModel!.assetsType![self.assetIndexForInit]
        setUpViews()
        if !self.loading {
            reloadWalletData()
        }
//        if self.walletModel!.coinType == CoinType.BTC {
//            self.reloadBtcData()
//        } else if self.walletModel!.coinType == CoinType.ETH {
//            self.reloadEthData()
//        }
    }

	private func setUpViews() {
		self.navTitleLabel.text = SWLocalizedString(key: "asset_detail")
        self.title1Label.text = SWLocalizedString(key: "transaction_records")
        self.sendBtn.setTitle(SWLocalizedString(key: "send"), for: .normal)
        self.receiveBtn.setTitle(SWLocalizedString(key: "receive"), for: .normal)
        self.emptyLbl.text = SWLocalizedString(key: "no_tx_log")
        
        if self.walletModel?.extendedPrivateKey == nil {
//            self.sendBtn.isUserInteractionEnabled = false
            self.sendBtn.setBackgroundImage(UIImage.init(color: UIColor.init(hexColor: "dddddd")), for: .normal)
        }
        
        self.topCardView = AssetsDetailHeaderCardView.init(frame: CGRect.init(x: 15, y: 8, width: 200, height: 120))
        self.topCardView?.setContent(model: self.selectedAsset!)
        self.topView.addSubview(self.topCardView!)
        
        self.topCollectionView = AssetsDetailHeaderCollectionView.init()
        self.topCollectionView!.cellHeight = 54
        self.topCollectionView!.setData(assets: self.walletModel!.assetsType!, index: self.assetIndexForInit)
        self.topCollectionView!.assetsDelegate = self
        self.topView.addSubview(self.topCollectionView!)
        self.topCollectionView!.snp.makeConstraints { (make) in
            make.left.equalTo(self.topCardView!.snp.right).offset(10)
            make.top.equalTo(self.topCardView!).offset(-3)
            make.right.equalTo(0)
            make.height.equalTo(self.topCollectionView!.cellHeight)
        }

        logTabView.delegate = self
		logTabView.dataSource = self
		logTabView.separatorStyle = .none
		logTabView.backgroundColor = logTabView.superview?.backgroundColor
        logTabView.register(UINib.init(nibName: "TransactionListCell", bundle: nil), forCellReuseIdentifier: "TransactionLogTabViewCell")
        self.logTabView.mj_header = SwiftDiyHeader(refreshingBlock: {
            self.reloadWalletData()
        })
        self.logTabView.mj_header.lastUpdatedTimeKey = "AssetsDetailViewContoller"
//        logTabView.register(UINib.init(nibName: "TransactionLogTabViewCell", bundle: nil), forCellReuseIdentifier: "TransactionLogTabViewCell")
	}
    
//    private func reloadBtcData() {
//        let address = (self.walletModel?.extendedPublicKey)!
//        BtcAPIProvider.request(BtcAPI.btcTransactionList(address, 0, 20)) { [weak self] (result) in
//            switch result {
//            case let .success(response):
//                let json = try? JSONDecoder().decode(BtcTransactionListModel.self, from: response.data)
//                if json?.errcode != 0 {
//                    print(json?.msg ?? "get transaction list error")
//                    return
//                }
//                let uniArray = self?.convertData(dataArray: (json?.data)!)
//                self?.transactionArr = uniArray
//                self?.logTabView.reloadData()
//            case let .failure(error):
//                print("error = \(error)")
//            }
//        }
//    }
//
//    private func reloadEthData() {
//        let address = (self.walletModel?.extendedPublicKey)!
//        let contractAddress = self.selectedAsset!.contractAddress
//        EthAPIProvider.request(EthAPI.ethTransactionList(address, contractAddress!, 1, 20)) { [weak self] (result) in
//            switch result {
//            case let .success(response):
//                let json = try? JSONDecoder().decode(EthTransactionListModel.self, from: response.data)
//                if json?.errcode != 0 {
//                    print(json?.msg ?? "request for transaction list error")
//                    return
//                }
//                let uniArray = self?.convertData(dataArray: (json?.data)!)
//                self?.transactionArr = uniArray
//                self?.logTabView.reloadData()
//            case let .failure(error):
//                print("request for transaction list error:\n\(error)")
//            }
//        }
//    }
    
    
    private func reloadWalletData() {
        
        self.btcPage = 0
        self.ethPage = 1
        if let type = self.walletModel?.coinType {
            switch type {
            case .BTC:
                self.requestBtcData(offset: self.btcPage)
            case .ETH:
                self.requestEthData(page: self.ethPage)
            case .LTC:
                self.requestLtcData(offset: self.btcPage)
            }
        }
//        if self.walletModel!.coinType == CoinType.BTC {
//            self.requestBtcData(offset: self.btcPage)
//        } else if self.walletModel!.coinType == CoinType.ETH {
//            self.requestEthData(page: self.ethPage)
//        }
    }
    
    private func requestBtcData(offset: Int) {
        guard let address = self.walletModel?.extendedPublicKey else {
            return
        }
        self.loading = true
        BtcAPIProvider.request(BtcAPI.btcTransactionList(address, offset, 10)) { [weak self] (result) in
            self?.logTabView.mj_header.endRefreshing()
            self?.loading = false
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(BtcTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get transaction list error")
                    return
                }
                if offset == 0 {
                    self?.transactionArr.removeAll()
                }
                guard let data = json?.data,
                    let wallet = self?.walletModel,
                    let uniArray = SwiftWalletManager.shared.convertData(walletModel: wallet, asset: self?.selectedAsset, dataArray: data) else
                {
                        if offset == 0 {
                            self?.emptyView.isHidden = false
                        }
                        return
                }
                if uniArray.count > 0 {
                    self?.emptyView.isHidden = true
                }
                if self?.logTabView.delegate == nil {
                    self?.logTabView.delegate = self
                    self?.logTabView.dataSource = self
                }
                self?.transactionArr += uniArray
                self?.logTabView.reloadData()
                self?.btcPage += 1
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    private func requestLtcData(offset: Int) {
        guard let address = self.walletModel?.extendedPublicKey else {
            return
        }
        self.loading = true
        LtcAPIProvider.request(LtcAPI.ltcTransactionList(address, offset, 10)) { [weak self] (result) in
            self?.logTabView.mj_header.endRefreshing()
            self?.loading = false
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(ltcTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get transaction list error")
                    return
                }
                if offset == 0 {
                    self?.transactionArr.removeAll()
                }
                guard let data = json?.data,
                    let wallet = self?.walletModel,
                    let uniArray = SwiftWalletManager.shared.convertData(walletModel: wallet, asset: self?.selectedAsset, dataArray: data) else
                {
                    if offset == 0 {
                        self?.emptyView.isHidden = false
                    }
                    return
                }
                if uniArray.count > 0 {
                    self?.emptyView.isHidden = true
                }
                if self?.logTabView.delegate == nil {
                    self?.logTabView.delegate = self
                    self?.logTabView.dataSource = self
                }
                self?.transactionArr += uniArray
                self?.logTabView.reloadData()
                self?.btcPage += 1
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    private func requestEthData(page: Int) {
        guard let address = self.walletModel?.extendedPublicKey,
        let contractAddress = self.selectedAsset!.contractAddress
            else {
            return
        }
        
        self.loading = true
        EthAPIProvider.request(EthAPI.ethTransactionList(address, contractAddress, page, 10)) { [weak self] (result) in
            self?.logTabView.mj_header.endRefreshing()
            self?.loading = false
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(EthTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "request for transaction list error")
                    return
                }
                if self?.selectedAsset?.contractAddress != contractAddress {
                    return
                }
                if page == 1 {
                    self?.transactionArr.removeAll()
                }
                guard let data = json?.data,
                    let wallet = self?.walletModel,
                    let uniArray = SwiftWalletManager.shared.convertData(walletModel: wallet, asset: self?.selectedAsset, dataArray: data) else
                {
                    if page == 1 {
                        self?.emptyView.isHidden = false
                    }
                    return
                }
                if uniArray.count > 0 {
                    self?.emptyView.isHidden = true
                }
                if self?.logTabView.delegate == nil {
                    self?.logTabView.delegate = self
                    self?.logTabView.dataSource = self
                }
                self?.transactionArr += uniArray
                self?.logTabView.reloadData()
                self?.ethPage += 1
            case let .failure(error):
                print("request for transaction list error:\n\(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    private func loadMoreData() {
        if let type = self.walletModel?.coinType {
            switch type {
            case .BTC:
                self.requestBtcData(offset: self.btcPage * 10)
            case .LTC:
                self.requestLtcData(offset: self.btcPage * 10)
            case .ETH:
                self.requestEthData(page: self.ethPage)
            }
        }
    }
//    
//    private func convertData(dataArray: [Any]) -> [UniversalTransactionModel]? {
//        if dataArray.count == 0 {
//            return nil
//        }
//        
//        var uniArray:[UniversalTransactionModel] = []
//        
//        for (index, object) in dataArray.enumerated() {
//            var uniModel = UniversalTransactionModel()
//            if let type = self.walletModel?.coinType {
//                switch type {
//                case .BTC:
//                    let btcModel = object as! BtcTransactionModel
//                    uniModel.ID = btcModel.txid
//                    let amount = calculateAmount(transaction: btcModel)
//                    if amount >= 0 {
//                        uniModel.isIn = true
//                        uniModel.amount = amount
//                    } else {
//                        uniModel.isIn = false
//                        uniModel.amount = -1 * amount
//                    }
//                    if uniModel.isIn! {
//                        if btcModel.from_address == nil {
//                            uniModel.from = "Newly Generated"
//                        } else {
//                            for from in btcModel.from_address! {
//                                if from.addr != self.walletModel?.extendedPublicKey {
//                                    uniModel.from = from.addr
//                                    break
//                                }
//                            }
//                        }
//                        uniModel.to = self.walletModel?.extendedPublicKey
//                    } else {
//                        for to in btcModel.to_address! {
//                            if to.addr != self.walletModel?.extendedPublicKey {
//                                uniModel.to = to.addr
//                                break
//                            }
//                        }
//                        uniModel.from = self.walletModel?.extendedPublicKey
//                    }
//                    uniModel.fee = Decimal(string: btcModel.fees!)?.description
//                    uniModel.blockHeight = btcModel.blockheight
//                    uniModel.confirmations = btcModel.confirmations
//                    uniModel.coinType = CoinType.BTC
//                    var interval = Date().timeIntervalSince1970
//                    if btcModel.blocktime != nil,
//                        let temp = TimeInterval(btcModel.blocktime!),
//                        temp > 1230739200
//                    {
//                        interval = temp
//                    }
//                    let date = Date(timeIntervalSince1970: interval)
//                    let dateformatter = DateFormatter()
//                    dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
//                    dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
//                    let dateStr = dateformatter.string(from: date)
//                    uniModel.time = dateStr
//                    uniModel.timeInterval = interval
//                case .LTC:
//                    let btcModel = object as! BtcTransactionModel
//                    uniModel.ID = btcModel.txid
//                    let amount = calculateAmount(transaction: btcModel)
//                    if amount >= 0 {
//                        uniModel.isIn = true
//                        uniModel.amount = amount
//                    } else {
//                        uniModel.isIn = false
//                        uniModel.amount = -1 * amount
//                    }
//                    if uniModel.isIn! {
//                        if btcModel.from_address == nil {
//                            uniModel.from = "Newly Generated"
//                        } else {
//                            for from in btcModel.from_address! {
//                                if from.addr != self.walletModel?.extendedPublicKey {
//                                    uniModel.from = from.addr
//                                    break
//                                }
//                            }
//                        }
//                        uniModel.to = self.walletModel?.extendedPublicKey
//                    } else {
//                        for to in btcModel.to_address! {
//                            if to.addr != self.walletModel?.extendedPublicKey {
//                                uniModel.to = to.addr
//                                break
//                            }
//                        }
//                        uniModel.from = self.walletModel?.extendedPublicKey
//                    }
//                    uniModel.fee = Decimal(string: btcModel.fees!)?.description
//                    uniModel.blockHeight = btcModel.blockheight
//                    uniModel.confirmations = btcModel.confirmations
//                    uniModel.coinType = CoinType.BTC
//                    var interval = Date().timeIntervalSince1970
//                    if btcModel.blocktime != nil,
//                        let temp = TimeInterval(btcModel.blocktime!),
//                        temp > 1230739200
//                    {
//                        interval = temp
//                    }
//                    let date = Date(timeIntervalSince1970: interval)
//                    let dateformatter = DateFormatter()
//                    dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
//                    dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
//                    let dateStr = dateformatter.string(from: date)
//                    uniModel.time = dateStr
//                    uniModel.timeInterval = interval
//                case .ETH:
//                    let ethModel = object as! EthTransactionListDataModel
//                    uniModel.ID = ethModel.hash
//                    uniModel.from = ethModel.from
//                    uniModel.to = ethModel.to
//                    let amount = try? Converter.toEther(wei: Wei.init(ethModel.value!)!)
//                    uniModel.amount = amount
//                    let fee = try? Converter.toEther(wei: Wei.init(BInt(ethModel.gas!)! * BInt(ethModel.gasPrice!)!))
//                    if ethModel.to == self.walletModel?.extendedPublicKey?.lowercased() {
//                        uniModel.isIn = true
//                    } else {
//                        uniModel.isIn = false
//                    }
//                    uniModel.fee = fee?.description
//                    uniModel.blockHeight = ethModel.blockNumber
//                    uniModel.confirmations = ethModel.confirmedNum
//                    uniModel.coinType = CoinType.ETH
//                    var interval = Date().timeIntervalSince1970
//                    if let stamp = ethModel.timestamp,
//                        let temp = TimeInterval(stamp),
//                        temp > 1230739200
//                    {
//                        interval = temp
//                    }
//                    let date = Date(timeIntervalSince1970: interval)
//                    let dateformatter = DateFormatter()
//                    dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
//                    dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
//                    let dateStr = dateformatter.string(from: date)
//                    uniModel.time = dateStr
//                    uniModel.timeInterval = interval
//                    uniModel.gasPrice = ethModel.gasPrice
//                    uniModel.assetSymbol = self.selectedAsset?.symbol
//                    uniModel.assetIconUrl = self.selectedAsset?.iconUrl
//                }
//            }
//            if let confirmations = uniModel.confirmations {
//                if confirmations < 0 {
//                    uniModel.state = 3
//                } else if confirmations < 6 {
//                    uniModel.state = 2
//                } else {
//                    uniModel.state = 1
//                }
//            }
//            uniArray.append(uniModel)
//        }
//        return uniArray
//    }
//    
//    private func calculateAmount(transaction:BtcTransactionModel) -> Decimal {
//        var amount = Decimal()
//        for transfer in transaction.from_address! {
//            if transfer.addr == self.walletModel?.extendedPublicKey {
//                amount -= Decimal.init(string: transfer.value!)!
//            }
//        }
//        for transfer in transaction.to_address! {
//            if transfer.addr == self.walletModel?.extendedPublicKey {
//                amount += Decimal.init(string: transfer.value!)!
//            }
//        }
//        return amount
//    }
	
	@IBAction func clickSendBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Send_AssetsDetail_Page)
        if self.walletModel?.extendedPrivateKey == nil {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_NoSend_Prompt_AssetDetail_page)
            self.noticeOnlyText(SWLocalizedString(key: "watch_send_denial"))
            return
        }
        let sendVC = TransferAccountsViewController.init(nibName: "TransferAccountsViewController", bundle: nil)
        sendVC.walletModel = self.walletModel
		sendVC.assetType = self.selectedAsset
        self.present(sendVC, animated: true) {
            
        }
//        self.navigationController?.pushViewController(sendVC, animated: true)
	}
	@IBAction func clickReceiveBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Receive_AssetsDetail_Page)
        let createWalletVC = GenerateQRCodeViewController.init(nibName: "GenerateQRCodeViewController", bundle: nil)
        createWalletVC.view.backgroundColor = UIColor.white.withAlphaComponent(0)
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        createWalletVC.view.addSubview(blurView)
        createWalletVC.view.sendSubview(toBack: blurView)
        //        createWalletVC.transitioningDelegate = self
        createWalletVC.modalPresentationStyle = .custom
        createWalletVC.walletAddress = self.walletModel!.extendedPublicKey!
        createWalletVC.receivingCodeLabel.text = self.walletModel!.walletName!
        createWalletVC.logoImageView.image = UIImage.init(named: self.walletModel!.walletImage!)
        self.present(createWalletVC, animated: true, completion: nil)
	}
	@IBAction func clickBackBtn(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
}
