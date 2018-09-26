//
//  AllChildViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/23.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

protocol ExchangChildDelegate: class {
    func exchangeChildDidSelect(child: ExchangeChildViewController, vc: TransactionPairDetailViewController)
}

class ExchangeChildViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FavoritesButtonActionDelegate {
    
    weak var delegate: ExchangChildDelegate?
    
    private var exchangeDataArr:[MarketsCoinPairDataModel] = []
    
    var exchangeNameTagSelectedKey : String = "" {
        didSet {
            let oldKey = exchangeSortingKeyArray[oldValue]
            if oldKey != self.exchangeSortSelectedKey {
                if oldKey == nil {
                    self.exchangeSortSelectedKey = MarketsCoinPairsSortParamKey.vo_desc.rawValue
                }
                exchangeSortingKeyArray[oldValue] = self.exchangeSortSelectedKey
                UserDefaults.standard.set(exchangeSortingKeyArray, forKey: exchangeSortingArrayStoreKey)
                UserDefaults.standard.synchronize()
            }
            if let keyStr = exchangeSortingKeyArray[exchangeNameTagSelectedKey] {
                if let key = MarketsCoinPairsSortParamKey(rawValue: keyStr) {
                    self.exchangeSortSelectedKey = key.rawValue
                }
            }
            reloadAll()
        }
    }
    private var exchangeSortSelectedKey = MarketsCoinPairsSortParamKey.vo_desc.rawValue
    
    private let originY: CGFloat = 0//35.0
    
    private lazy var exchangeSortingHeaderView : ExchangeHeaderView = {
        let headView : ExchangeHeaderView = Bundle.main.loadNibNamed("ExchangeHeaderView", owner: self, options: nil)?.last as! ExchangeHeaderView
        headView.frame = CGRect.init(x: 0, y: 35, width: SWScreen_width, height: 34)
        headView.itemTitles = [SWLocalizedString(key: "ex_vol"),SWLocalizedString(key: "price"),SWLocalizedString(key: "change")]
        headView.setDefaultSelectedItem(btnTag: 0)
        headView.buttonSelectedBlock = { [weak self] (btnTag, sortKey) in
            if btnTag == 0 {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_volRank_ExHomePage)
            } else if btnTag == 1 {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_PriceRank_ExHomePage)
            } else {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ChangeRank_ExHomePage)
            }
            self?.exchangeSortSelectedKey = sortKey
            self?.requestNetworkExchangePairsData(exchangeName: (self?.exchangeNameTagSelectedKey)!, sortKey: sortKey, offset: 0)
            
        }
        return headView
    }()
    private lazy var exchangeTableView: UITableView = {
        var space:CGFloat = 0
        if SWScreen_height == 812 {
            space = 28
        }
        let tab : UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 34, width: SWScreen_width, height: SWScreen_height-SafeAreaTopHeight-space-34-49), style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        tab.register(UINib.init(nibName: "MarketPairCell", bundle: nil), forCellReuseIdentifier: "MarketPairCell")
        tab.separatorStyle = .none
        tab.rowHeight = 60
        tab.showsVerticalScrollIndicator = false
        return tab
    }()
    
    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        return failView
    }()
    
    //MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDataView()
        
        view.addSubview(exchangeTableView)
    }
    
    //MARK: - Load subview
    func loadFailedView() {
        self.exchangeDataArr.removeAll()
        self.exchangeTableView.reloadData()
        self.exchangeTableView.addSubview(networkFailView)
        networkFailView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-42)
        }
    }
    
    func loadDataView()  {
        view.addSubview(exchangeSortingHeaderView)
        
        exchangeSortingHeaderView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(originY)
            make.width.equalTo(SWScreen_width)
            make.height.equalTo(34)
        }
        
        
        // Do any additional setup after loading the view.wan'yi
        exchangeTableView.mj_header = SwiftDiyHeader(refreshingBlock: {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_icon, eventPrame: "exchange")
            self.requestNetworkExchangePairsData(exchangeName: self.exchangeNameTagSelectedKey, sortKey: self.exchangeSortSelectedKey, offset: 0)
            
        })
        exchangeTableView.mj_header.lastUpdatedTimeKey = "ExchangeViewController"
        exchangeTableView.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            self.requestNetworkExchangePairsData(exchangeName: self.exchangeNameTagSelectedKey, sortKey: self.exchangeSortSelectedKey, offset: self.exchangeDataArr.count)
        })
//        self.requestNetworkExchangePairsData(exchangeName: self.exchangeNameTagSelectedKey, sortKey: self.exchangeSortSelectedKey, offset: self.exchangeDataArr.count)
        exchangeTableView.mj_header.beginRefreshing()
    }
    
    //MARK: - Action
    func requestNetworkExchangePairsData(exchangeName: String, sortKey:String, offset: Int) {
        
        MarketsAPIProvider.request(MarketsAPI.markets_exchangePairs(exchangeName, sortKey, offset, 20)) { [weak self](result) in
            self?.exchangeTableView.mj_header.endRefreshing()
            self?.exchangeTableView.mj_footer.endRefreshing()
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_completed_icon, eventPrame: "exchange")
            self?.networkFailView.removeFromSuperview()
            
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                if decryptedData.count == 0 {
                    print("decryptedData is nil")
                    return
                }
                let json = try? JSONDecoder().decode(MarketsCoinPairModel.self, from: decryptedData)
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("json: \(String(describing: json ?? nil))")
                    return
                }
                if  (offset != 0) && (json?.data?.count == 0) {
                    self?.exchangeTableView.mj_footer.state = MJRefreshState.noMoreData
                    self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
                    return
                }
                DispatchQueue.main.async {
                    if offset == 0 {
                        self?.exchangeDataArr.removeAll()
                    }
                    for symbol:MarketsCoinPairDataModel in (json?.data)! {
                        self?.exchangeDataArr.append(symbol)
                    }
                    self?.exchangeTableView.reloadData()
                    if offset == 0 && self?.exchangeDataArr.count != 0 {
                        self?.exchangeTableView.scrollToRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: true)
                    }
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.loadFailedView()
            }
        }
        
    }
    //     favorites
    func favoritesRequest(symbol: String, exchange: String, pair: String, isFavorite: Bool, arrIndex: Int) {
        MarketsAPIProvider.request(MarketsAPI.markets_currencyFavorite(symbol, exchange, pair, isFavorite)) { [weak self] (result) in
            if case let .success(response) = result {
                
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
                if json?.code != 0 {
                    let msg = isFavorite ? SWLocalizedString(key: "add_failure") : SWLocalizedString(key: "cancel_failure")
                    self?.noticeOnlyText(msg)
                    print("currencyFavorite response json: \(String(describing: json ?? nil))")
                    return
                }
                var symbol:MarketsCoinPairDataModel = (self?.exchangeDataArr[arrIndex])!
                symbol.favorite_status = isFavorite ? 1 : 2
                self?.exchangeDataArr.remove(at: arrIndex)
                self?.exchangeDataArr.insert(symbol, at: arrIndex)
                
                self?.exchangeTableView.reloadRows(at: [IndexPath.init(row: arrIndex, section: 0)], with: UITableViewRowAnimation.none)
                
                let msg = isFavorite ? SWLocalizedString(key: "add_success") : SWLocalizedString(key: "cancel_success")
                self?.noticeOnlyText(msg)
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "cancel_failure"))
            }
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exchangeDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MarketPairCell = tableView.dequeueReusableCell(withIdentifier: "MarketPairCell") as! MarketPairCell
        cell.selectionStyle = .none
        let model :MarketsCoinPairDataModel = self.exchangeDataArr[indexPath.row]
        cell.setContent(model: model, indexPath: indexPath)
        cell.delegate_favor = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < self.exchangeDataArr.count {
            let vc:TransactionPairDetailViewController = TransactionPairDetailViewController()
            let symbol:MarketsCoinPairDataModel = self.exchangeDataArr[indexPath.row]
            vc.reloadFavoriteStatusClosure = { (status:Int) in
                print("\(status)")
                var symbol = self.exchangeDataArr[indexPath.row]
                symbol.favorite_status = status
                self.exchangeDataArr[indexPath.row] = symbol
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
            vc.coinPair = symbol
            vc.hidesBottomBarWhenPushed = true
            self.delegate?.exchangeChildDidSelect(child: self, vc: vc)
//            self.view.superview?.viewController().navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    private func reloadAll() {
        if let key = MarketsCoinPairsSortParamKey(rawValue: self.exchangeSortSelectedKey) {
            self.exchangeSortingHeaderView.setButtonState(sortKey: key)
        }
        self.exchangeDataArr.removeAll()
        self.requestNetworkExchangePairsData(exchangeName: self.exchangeNameTagSelectedKey, sortKey: self.exchangeSortSelectedKey, offset: self.exchangeDataArr.count)
    }
    
    //MARK: cell favorites delegate
    //    func swipeTableCellWillEndSwiping(_ cell: MGSwipeTableCell) {
    //        let indexPath = self.exchangeTableView.indexPath(for: cell)
    //        if indexPath == nil {
    //            return
    //        }
    //        let symbol:MarketsCoinPairDataModel = self.exchangeDataArr[indexPath!.row]
    //        let eventName = symbol.favorite_status == 1 ? SWUEC_Show_AddFavorites_ExHomePage : SWUEC_Show_CancelFavorites_ExHomePage
    //        SPUserEventsManager.shared.addCount(forEvent: eventName)
    //    }
    
    func favoritesButtonAction(indexPath: IndexPath) {
        
        let model :MarketsCoinPairDataModel = self.exchangeDataArr[indexPath.row]
        let favState = model.favorite_status == 1 ?  false : true
        self.favoritesRequest(symbol: model.symbol!, exchange: model.exchange!, pair:model.pair!, isFavorite: favState, arrIndex: indexPath.row)
        
        let eventName = model.favorite_status == 1 ? SWUEC_Click_AddFavorites_ExHomePage : SWUEC_Click_CancelFavorites_ExHomePage
        SPUserEventsManager.shared.addCount(forEvent: eventName)
    }
    
    //MARK: - dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
