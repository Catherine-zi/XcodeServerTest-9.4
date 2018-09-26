//
//  TransactionListViewController.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/12.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit

class TransactionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var walletSelectView: UIView!
    @IBOutlet weak var walletDecoView: UIImageView!
    @IBOutlet weak var walletImgView: UIImageView!
    @IBOutlet weak var walletNameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var walletSingleNameLbl: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var netErrorView: UIView!
    @IBOutlet weak var netErrorLbl: UILabel!
    
    var walletArr:[SwiftWalletModel] = []
    private var btcPage: Int = 0 // get by offset from 0
    private var ethPage: Int = 1 // get by page from 1
    private var loading: Bool = false
    private var noMore: Bool = false
    private var fommerCountForEth = 0
    var selectedIndex:Int = 0 {
        didSet {
            if self.walletArr.count > self.selectedIndex {
                self.selectedWalletModel = self.walletArr[self.selectedIndex]
            }
        }
    }
    var selectedWalletModel:SwiftWalletModel? {
        didSet {
//            self.reloadWalletData()
        }
    }
    var filteAddress: String? // 选择初始钱包
    var transactionArr:[UniversalTransactionModel] = []
    var oriTransactionArr:[UniversalTransactionModel] = []
    var selectView:WalletSelectView?
    var visualView:UIVisualEffectView?
    lazy private var refreshHeader = {
        return SwiftDiyHeader(refreshingBlock: {
            self.reloadWalletData()
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_TransactionRecord_Page)

        self.setUpViews()
        if self.selectedWalletModel != nil {
            self.reloadWalletData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpViews() {
        self.titleLbl.text = SWLocalizedString(key: "transaction_records")
        self.emptyLbl.text = SWLocalizedString(key: "no_tx_log")
        self.netErrorLbl.text = SWLocalizedString(key: "network_error")
        
        self.walletArr = SwiftWalletManager.shared.walletArr
        if self.walletArr.count == 0 {
            self.searchBtn.isHidden = true
            self.walletSelectView.isHidden = true
            self.walletDecoView.isHidden = true
            self.setHintViewShow(type: "empty")
            return
        }
        
        if self.filteAddress != nil {
            for (index, wallet) in self.walletArr.enumerated() {
                if wallet.extendedPublicKey?.lowercased() == self.filteAddress?.lowercased() {
                    self.selectedIndex = index
                    break
                }
            }
        }
        
        self.searchField.placeholder = SWLocalizedString(key: "search_hint_transaction_record")
        
        if self.walletArr.count > self.selectedIndex {
            self.selectedWalletModel = self.walletArr[self.selectedIndex]
        }
        self.searchField.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets.init(top: 30, left: 0, bottom: 0, right: 0)
        self.tableView.register(UINib.init(nibName: "TransactionListCell", bundle: nil), forCellReuseIdentifier: "transactionListCell")
        self.tableView.mj_header = self.refreshHeader
        self.tableView.mj_header.ignoredScrollViewContentInsetTop = 30
        self.tableView.mj_header.lastUpdatedTimeKey = "TransactionListViewContoller"
    }
    
    private func reloadWalletData() {
        
        if self.selectedWalletModel == nil {
            return
        }
        
        if self.selectedWalletModel!.walletImage != nil {
            self.walletImgView.image = UIImage.init(named: self.selectedWalletModel!.walletImage!)
        }
        self.walletNameLbl.text = self.selectedWalletModel!.walletName
        self.walletSingleNameLbl.text = self.selectedWalletModel!.walletName
        
        self.btcPage = 0
        self.ethPage = 1
        self.fommerCountForEth = 0
        self.noMore = false
        self.loadMoreData()
    }
    
    private func requestBtcData(offset: Int) {
        guard let address = self.selectedWalletModel?.extendedPublicKey else {
            return
        }
        self.loading = true
        BtcAPIProvider.request(BtcAPI.btcTransactionList(address, offset, 10)) { [weak self] (result) in
            if self?.tableView.mj_header != nil {
                self?.tableView.mj_header.endRefreshing()
            }
            self?.loading = false
            switch result {
            case let .success(response):
                if self?.selectedWalletModel?.extendedPublicKey != address {
                    return
                }
                let json = try? JSONDecoder().decode(BtcTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get transaction list error")
                    if self?.oriTransactionArr.count == 0 {
                        self?.setHintViewShow(type: "empty")
                    }
                    return
                }
                self?.setHintViewShow(type: "none")
                if self?.btcPage == 0 {
                    self?.oriTransactionArr.removeAll()
                    self?.transactionArr.removeAll()
                }
                guard let data = json?.data,
                    let uniArray = self?.convertData(dataArray: data, asset: nil)
                else {
                    self?.noMore = true
                    if self?.btcPage == 0 {
                        self?.setHintViewShow(type: "empty")
                    }
                    return
                }
                if uniArray.count > 0 {
                    self?.setHintViewShow(type: "none")
                    self?.noMore = false
                }
                if self?.tableView.delegate == nil {
                    self?.tableView.delegate = self
                    self?.tableView.dataSource = self
                }
                self?.oriTransactionArr += uniArray
                self?.transactionArr += uniArray
                self?.tableView.reloadData()
                if self?.oriTransactionArr != nil {
                    SPUserEventsManager.shared.trackEventAction(SWUEC_Show_TransactionList, eventPrame: (self!.oriTransactionArr.count > 0 ? "1" : "0"))
                }
                self?.btcPage += 1
            case let .failure(error):
                print("error = \(error)")
                self?.setHintViewShow(type: "net")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
            }
        }
    }
    
    private func requestEthData(asset: AssetsTokensModel, page: Int, group: DispatchGroup) {
        guard let address = self.selectedWalletModel?.extendedPublicKey else {
            return
        }
        self.loading = true
        group.enter()
        EthAPIProvider.request(EthAPI.ethTransactionList(address, asset.contractAddress!, page, 10)) { [weak self] (result) in
            if self?.tableView.mj_header != nil {
                self?.tableView.mj_header.endRefreshing()
            }
            switch result {
            case let .success(response):
                let json = try? JSONDecoder().decode(EthTransactionListModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "request for transaction list error")
                    group.leave()
                    return
                }
//                if self?.ethPage == 1 {
//                    self?.oriTransactionArr.removeAll()
//                    self?.transactionArr.removeAll()
//                }
                self?.setHintViewShow(type: "none")
                guard let data = json?.data,
                    let uniArray = self?.convertData(dataArray: data, asset: asset)
                else {
//                    if self?.ethPage == 1 {
//                        self?.emptyView.isHidden = false
//                    }
                    group.leave()
                    return
                }
                if uniArray.count > 0 {
                    self?.setHintViewShow(type: "none")
                    self?.noMore = false
                }
                if self?.tableView.delegate == nil {
                    self?.tableView.delegate = self
                    self?.tableView.dataSource = self
                }
                self?.oriTransactionArr += uniArray
                self?.transactionArr += uniArray
                group.leave()
//                self?.tableView.reloadData()
//                self?.ethPage += 1
            case let .failure(error):
                print("request for transaction list error:\n\(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.setHintViewShow(type: "net")
                group.leave()
            }
        }
    }
    
    private func loadMoreData() {
        if self.selectedWalletModel?.coinType == CoinType.BTC {
            self.requestBtcData(offset: self.btcPage * 10)
        } else if self.selectedWalletModel!.coinType == CoinType.ETH {
            let group = DispatchGroup()
            if self.ethPage == 1 {
                self.oriTransactionArr.removeAll()
                self.transactionArr.removeAll()
            }
            if let assets = self.selectedWalletModel!.assetsType {
                for asset in assets {
                    if let _ = asset.contractAddress {
                        self.requestEthData(asset: asset, page: self.ethPage, group: group)
                    }
                }
            }
            let privHash = self.selectedWalletModel?.extendedPrivateKey
            group.notify(queue: .main, execute: {
                if self.selectedWalletModel?.extendedPrivateKey != privHash {
                    return
                }
                self.loading = false
                if self.oriTransactionArr.count > 0 {
                    self.setHintViewShow(type: "none")
                }
                SPUserEventsManager.shared.trackEventAction(SWUEC_Show_TransactionList, eventPrame: (self.oriTransactionArr.count > 0 ? "1" : "0"))
                if self.oriTransactionArr.count > self.fommerCountForEth {
//                    self.oriTransactionArr.sort(by: { $1.timeInterval!.isLessThanOrEqualTo($0.timeInterval!) })
                    if let arr = self.sortArray(parentList: self.oriTransactionArr) {
                        self.oriTransactionArr = arr
                        self.transactionArr = self.oriTransactionArr
                        self.tableView.reloadData()
                        self.ethPage += 1
                    }
                } else {
                    self.noMore = true
                    if self.ethPage == 1 && self.oriTransactionArr.count == 0 && self.netErrorView.isHidden {
                        self.setHintViewShow(type: "empty")
                    }
                }
                self.fommerCountForEth = self.oriTransactionArr.count
            })
        }
    }
    
    private func sortArray(parentList: [UniversalTransactionModel]) -> [UniversalTransactionModel]? {
        
        let sortedArray = (parentList as NSArray).sortedArray(options: .stable, usingComparator: ({ (lhs, rhs) -> ComparisonResult in
            if let lhs = (lhs as? UniversalTransactionModel),
                let rhs = (rhs as? UniversalTransactionModel)
            {
                if lhs.timeInterval != nil && rhs.timeInterval != nil {
                    if lhs.timeInterval!.isEqual(to: rhs.timeInterval!) {
                        return .orderedSame
                    } else if lhs.timeInterval!.isLess(than: rhs.timeInterval!) {
                        return .orderedDescending
                    } else {
                        return .orderedAscending
                    }
                }
            }
            return .orderedSame
        }));
        return sortedArray as? [UniversalTransactionModel]
    }
    
    private func convertData(dataArray: [Any], asset: AssetsTokensModel?) -> [UniversalTransactionModel]? {
        if dataArray.count == 0 {
            return nil
        }
        
        var uniArray:[UniversalTransactionModel] = []
        
        for (index, object) in dataArray.enumerated() {
            var uniModel = UniversalTransactionModel()
            
            if self.selectedWalletModel?.coinType == CoinType.BTC && object is BtcTransactionModel {
                
                let btcModel = object as! BtcTransactionModel
                uniModel.ID = btcModel.txid
                if btcModel.fees != nil {
                    uniModel.fee = Decimal(string: btcModel.fees!)?.description
                }
                uniModel.blockHeight = btcModel.blockheight
                uniModel.confirmations = btcModel.confirmations
                uniModel.coinType = CoinType.BTC
                
                let amount = calculateAmount(transaction: btcModel)
                if amount >= 0 {
                    uniModel.isIn = true
                    uniModel.amount = amount
                } else {
                    uniModel.isIn = false
                    uniModel.amount = -1 * amount
                }
                if uniModel.isIn! {
                    if btcModel.from_address == nil {
                        uniModel.from = "Newly Generated"
                    } else {
                        for from in btcModel.from_address! {
                            if from.addr != self.selectedWalletModel?.extendedPublicKey {
                                uniModel.from = from.addr
                                break
                            }
                        }
                    }
                    uniModel.to = self.selectedWalletModel?.extendedPublicKey
                } else {
                    if btcModel.to_address != nil {
                        for to in btcModel.to_address! {
                            if to.addr != self.selectedWalletModel?.extendedPublicKey {
                                uniModel.to = to.addr
                                break
                            }
                        }
                    }
                    uniModel.from = self.selectedWalletModel?.extendedPublicKey
                }
                
                var interval = Date().timeIntervalSince1970
                if btcModel.blocktime != nil,
                    let temp = TimeInterval(btcModel.blocktime!),
                    temp > 1230739200
                {
                    interval = temp
                }
                let date = Date(timeIntervalSince1970: interval)
                let dateformatter = DateFormatter()
                dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
                dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
                let dateStr = dateformatter.string(from: date)
                uniModel.time = dateStr
                uniModel.timeInterval = interval
                
            } else if self.selectedWalletModel?.coinType == CoinType.ETH && object is EthTransactionListDataModel {
                
                let ethModel = object as! EthTransactionListDataModel
                uniModel.ID = ethModel.hash
                uniModel.from = ethModel.from
                uniModel.to = ethModel.to
                uniModel.blockHeight = ethModel.blockNumber
                uniModel.confirmations = ethModel.confirmedNum
                uniModel.coinType = CoinType.ETH
                
                if let value = ethModel.value,
                    let wei = Wei.init(value),
                    let amount = try? Converter.toEther(wei: wei)
                {
                    uniModel.amount = amount
                }
                if let gas = ethModel.gas,
                    let gasPrice = ethModel.gasPrice,
                    let gasBint = BInt(gas),
                    let gasPriceBint = BInt(gasPrice),
                    let fee =  try? Converter.toEther(wei: Wei.init(gasBint * gasPriceBint))
                {
                    uniModel.fee = fee.description
                }
                uniModel.gasPrice = ethModel.gasPrice
                if ethModel.to == self.selectedWalletModel?.extendedPublicKey?.lowercased() {
                    uniModel.isIn = true
                } else {
                    uniModel.isIn = false
                }
                
                var interval = Date().timeIntervalSince1970
                if let stamp = ethModel.timestamp,
                    let temp = TimeInterval(stamp),
                    temp > 1230739200
                {
                    interval = temp
                }
                let date = Date(timeIntervalSince1970: interval)
                let dateformatter = DateFormatter()
                dateformatter.locale = NSLocale(localeIdentifier: TelegramUserInfo.shareInstance.currentLanguage) as Locale?
                dateformatter.dateFormat = SWLocalizedString(key: "date_formatter")
                let dateStr = dateformatter.string(from: date)
                uniModel.time = dateStr
                uniModel.timeInterval = interval
                
                if asset != nil {
//                    if asset?.symbol = 
                    uniModel.assetSymbol = asset?.symbol
                    uniModel.assetIconUrl = asset?.iconUrl
                }
                
            } else {
                return nil
            }
            if let confirmations = uniModel.confirmations {
                if confirmations < 0 {
                    uniModel.state = 3
                } else if confirmations < 6 {
                    uniModel.state = 2
                } else {
                    uniModel.state = 1
                }
            }
            uniArray.append(uniModel)
        }
        return uniArray
    }
    
    private func calculateAmount(transaction:BtcTransactionModel) -> Decimal {
        var amount = Decimal()
        if transaction.from_address != nil {
            for transfer in transaction.from_address! {
                if transfer.value != nil {
                    if transfer.addr == self.selectedWalletModel?.extendedPublicKey {
                        if let decim = Decimal.init(string: transfer.value!) {
                            amount -= decim
                        }
                        break
                    }
                }
            }
        }
        if transaction.to_address != nil {
            for transfer in transaction.to_address! {
                if transfer.value != nil {
                    if transfer.addr == self.selectedWalletModel?.extendedPublicKey {
                        if let decim = Decimal.init(string: transfer.value!) {
                            amount += decim
                        }
                        break
                    }
                }
            }
        }
        return amount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
//            if self.transactionArr.count == 0 {
//                self.emptyView.isHidden = false
//            } else {
//                self.emptyView.isHidden = true
//            }
            return self.transactionArr.count
        } else {
            return self.walletArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 75
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell:TransactionListCell = tableView.dequeueReusableCell(withIdentifier: "transactionListCell", for: indexPath) as! TransactionListCell
            let model = self.transactionArr[indexPath.row]
            cell.setContent(data: model)

            return cell
        } else {
            let walletModel = self.walletArr[indexPath.row]
            let cell:WalletSelectCell = tableView.dequeueReusableCell(withIdentifier: "walletSelectCell", for: indexPath) as! WalletSelectCell
            cell.setContent(model: walletModel, isSelected: self.selectedIndex == indexPath.row)
            if indexPath.row == (self.walletArr.count - 1) {
                cell.separator.isHidden = true
            } else {
                cell.separator.isHidden = false
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let detailVC = TransactionDetailViewController()
            detailVC.type = self.selectedWalletModel?.coinType
            detailVC.transactionModel = self.transactionArr[indexPath.row]
            detailVC.walletModel = self.selectedWalletModel
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            self.selectedIndex = indexPath.row
            self.setHintViewShow(type: "none")
            tableView.reloadData()
            self.closeWalletChoose()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if (indexPath.row == self.transactionArr.count - 3) && self.searchView.isHidden {
                if !self.loading && !self.noMore {
                    self.loadMoreData()
                }
            }
        }
    }
    
    private func setHintViewShow(type: String) {
        switch type {
        case "empty":
            self.emptyView.isHidden = false
            self.netErrorView.isHidden = true
        case "net":
            self.emptyView.isHidden = true
            self.netErrorView.isHidden = false
        case "none":
            self.emptyView.isHidden = true
            self.netErrorView.isHidden = true
        default:
            self.emptyView.isHidden = true
            self.netErrorView.isHidden = true
        }
    }
    
    @IBAction func walletSelectTapped(_ sender: Any) {
        if self.visualView == nil {
            self.visualView = VisualEffectView.visualEffectView(frame:view.bounds)
            self.visualView!.isUserInteractionEnabled = true
            self.visualView!.isHidden = true
            self.view.addSubview(self.visualView!)
        }
        if self.selectView == nil {
            self.selectView = WalletSelectView()
            self.selectView!.tableDelegate = self
            self.selectView!.frame = CGRect.init(x: 15, y: 0.5 * (self.view.frame.size.height - 450), width: self.view.frame.size.width - 30, height: 450)
            self.visualView!.contentView.addSubview(self.selectView!)
            func closeTapped() {
//                self.closeWalletChoose()
                self.visualView?.isHidden = true
            }
            self.selectView?.closeBlock = closeTapped
        }
        self.visualView!.isHidden = false
    }
    
    private func closeWalletChoose() {
        self.visualView?.isHidden = true
        self.oriTransactionArr = []
        self.transactionArr = []
        self.tableView.reloadData()
        self.reloadWalletData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str:String = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        self.searchTransaction(string: str)
        
        return true
    }
    
    private func searchTransaction(string:String) {
        if (self.oriTransactionArr.count == 0) {
            return;
        }
        self.transactionArr.removeAll()
        if string.count > 0 {
            for model in self.oriTransactionArr {
                if model.ID != nil {
                    if model.ID!.contains(string) {
                        self.transactionArr.append(model)
                        continue
                    }
                }
                if (model.from != nil) {
                    if (model.from?.contains(string)) == true {
                        self.transactionArr.append(model)
                        continue
                    }
                }
                if (model.to != nil) {
                    if (model.from?.contains(string)) == true {
                        self.transactionArr.append(model)
                        continue
                    }
                }
            }
        } else {
            self.transactionArr = self.oriTransactionArr
        }
        self.tableView.reloadData()
    }
    
    private func recoverOriginalList() {
        self.transactionArr = self.oriTransactionArr
        self.tableView.reloadData()
    }
    
    private func displaySearchBar(show:Bool) {
        if show {
            self.tableView.mj_header = nil
            self.searchField.text = ""
            self.titleLbl.isHidden = true
            self.searchBtn.isHidden = true
            self.searchView.isHidden = false
            self.walletSelectView.isHidden = true
            self.walletDecoView.isHidden = true
            self.walletSingleNameLbl.isHidden = false
        } else {
            self.tableView.mj_header = self.refreshHeader
            self.titleLbl.isHidden = false
            self.searchBtn.isHidden = false
            self.searchView.isHidden = true
            self.walletSelectView.isHidden = false
            self.walletDecoView.isHidden = false
            self.walletSingleNameLbl.isHidden = true
            self.recoverOriginalList()
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func searchTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_seach_TransactionRecord_Page)
        self.displaySearchBar(show: true)
    }
    @IBAction func searchCancelTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Close_seach_TransactionRecord_Page)
        self.displaySearchBar(show: false)
    }
    
    struct UniversalTransactionModel:Codable {
        var isIn: Bool?
        var state: Int?
        var amount: Decimal?
        var ID: String?
        var time: String?
        var timeInterval: TimeInterval?
        var from: String?
        var to: String?
        var fee: String?
        var gasPrice: String?
        var blockHeight: String?
        var confirmations: Int?
        var coinType: CoinType?
        var assetIconUrl: String?
        var assetSymbol: String?
    }
    

}
