//
//  AllChildViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/23.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

enum MarketsAllTagSortParamKey: String {
    case ch_asc = "ch_asc"         //涨幅升序
    case ch_desc = "ch_desc"       //涨幅降序
    case vo_asc = "vo_asc"         //成交量升序
    case vo_desc = "vo_desc"       //成交量降序
    case cap_asc = "cap_asc"       //市值升序
    case cap_desc = "cap_desc"     //市值降序
    case price_asc = "price_asc"   //价格升序
    case price_desc = "price_desc" //价格降序
}
var MarketsAllTagSortSelectedKey = MarketsAllTagSortParamKey.cap_desc.rawValue

enum MarketsCoinPairsSortParamKey: String {
    case ch_asc = "price_usd_change_asc"         //涨幅升序
    case ch_desc = "price_usd_change_desc"       //涨幅降序
    case vo_asc = "vol_asc"         //成交量升序
    case vo_desc = "vol_desc"       //成交量降序
    //    case cap_asc = "cap_asc"       //市值升序
    //    case cap_desc = "cap_desc"     //市值降序
    case price_asc = "price_usd_asc"   //价格升序
    case price_desc = "price_usd_desc" //价格降序
}
var MarketsCoinPairsSortParamSelectedKey = MarketsCoinPairsSortParamKey.vo_desc.rawValue

protocol AllChildDelegate: class {
    func allChildDidSelect(child: AllChildViewController, vc: UIViewController)
}

class AllChildViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AllDataFavoritesButtonActionDelegate, FavoritesButtonActionDelegate {
    
    weak var delegate: AllChildDelegate?
    
    private var allDataArr:[MarketsAllDataStruct] = []
    private var coinPairArr:[MarketsCoinPairDataModel] = []
    
    var currentClickCoinKey = "All" {
        didSet {
            if oldValue != "All" {
                let oldKey = coinSortingKeyArray[oldValue]
                if oldKey != self.coinSortingKey.rawValue {
                    if oldKey == nil {
                        self.coinSortingKey = .vo_desc
                    }
                    coinSortingKeyArray[oldValue] = self.coinSortingKey.rawValue
                    UserDefaults.standard.set(coinSortingKeyArray, forKey: coinSortingArrayStoreKey)
                    UserDefaults.standard.synchronize()
                }
            }
            if currentClickCoinKey != "All" {
                if let keyStr = coinSortingKeyArray[currentClickCoinKey] {
                    if let key = MarketsCoinPairsSortParamKey(rawValue: keyStr) {
                        self.coinSortingKey = key
                    }
                }
            }
            reloadAll()
        }
    }
    var isShowTagWithAll : Bool {
        return currentClickCoinKey == "All" ? true : false
    }
    var coinSortingKey: MarketsCoinPairsSortParamKey = .vo_desc
    
    let header = MJRefreshNormalHeader()
    
    private let originY: CGFloat = 0//35.0
    
    private lazy var allTagSortTitleView : AllHeaderView = {
        let headView : AllHeaderView = Bundle.main.loadNibNamed("AllHeaderView", owner: nil, options: nil)?.last as! AllHeaderView
        headView.frame = CGRect.init(x: 0, y: originY, width: SWScreen_width, height: 34)
        headView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_down"), for: .selected)
        headView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_sorting"), for: .normal)
        
        headView.SelectedItemBlock = { [weak self] (btnTag, sortKey) in
            if btnTag == 0 {
                self?.screeningBtnClick()
            } else {
                btnTag == 1 ? SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Vol_Sorting_All_Page) :  SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Change_Sorting_All_Page)
                
                self?.requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: 0, limit: 20, mj_headerRefresh: false)
            }
        }
        return headView
    }()
    private lazy var screeningView: ScreeningPopView = {
        let view = Bundle.main.loadNibNamed("ScreeningPopView", owner: self, options: nil)?.first as! ScreeningPopView
        view.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: SWScreen_height)
        view.selectedKey = MarketsAllTagSortSelectedKey
        view.ScreeningButtonActionBlock = { [weak self] (button) in
            self?.screeningAction(sortBtn: button)
            if MarketsAllTagSortSelectedKey == MarketsAllTagSortParamKey.cap_desc.rawValue || MarketsAllTagSortSelectedKey == MarketsAllTagSortParamKey.price_desc.rawValue  {
                self?.allTagSortTitleView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_down"), for: .selected)
            } else {
                self?.allTagSortTitleView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_up"), for: .selected)
                
            }
        }
        return view
    }()
    private lazy var coinPairTagSortTitleView : ExchangeHeaderView = {
        let headView : ExchangeHeaderView = Bundle.main.loadNibNamed("ExchangeHeaderView", owner: nil, options: nil)?.last as! ExchangeHeaderView
        headView.frame = CGRect.init(x: 0, y: originY, width: SWScreen_width, height: 34)
        headView.itemTitles = [SWLocalizedString(key: "ex_vol"),SWLocalizedString(key: "price"),SWLocalizedString(key: "change")]
        headView.setDefaultSelectedItem(btnTag: 0)
        headView.buttonSelectedBlock = { [weak self] (btnTag, sortKey) in
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_volRank_Pairs_HomePage)
            if btnTag == 0 {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_volRank_Pairs_HomePage)
            } else if (btnTag == 1) {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_PriceRank_Pairs_HomePage)
            } else {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ChangeRank_Pairs_HomePage)
            }
            
            if let key = MarketsCoinPairsSortParamKey(rawValue: sortKey) {
                self?.coinSortingKey = key
            }
            self?.requestNetworkWithCoinPair(symbol: (self?.currentClickCoinKey)!, sortKey: sortKey, offset: 0, mj_headerRefresh: false)
            
        }
        return headView
    }()
    
    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        return failView
    }()
    
    private lazy var allTableView:UITableView = {
        var space:CGFloat = 0
        if SWScreen_height == 812 {
            space = 28
        }
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 34, width: SWScreen_width, height: SWScreen_height-SafeAreaTopHeight-space-34-49), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "AllTableViewCell", bundle: nil), forCellReuseIdentifier: "AllTableViewCell")
        tableView.register(UINib.init(nibName: "MarketPairCell", bundle: nil), forCellReuseIdentifier: "MarketPairCell")
        
        tableView.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        return tableView
    }()
    private var isRequestNetwork: Bool = false
    
    //MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDataView()
        view.addSubview(allTableView)
        view.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData(notif:)), name: SWNotificationName.gainsColor.notificationName, object: nil)
        
    }
    
    //MARK: - Load subview
    func loadDataView()  {
        
        if self.isShowTagWithAll {
            self.view.addSubview(self.allTagSortTitleView)
            allTagSortTitleView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(originY)
                make.width.equalTo(SWScreen_width)
                make.height.equalTo(34)
            }
        } else {
            self.view.addSubview(self.coinPairTagSortTitleView)
            coinPairTagSortTitleView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(originY)
                make.width.equalTo(SWScreen_width)
                make.height.equalTo(34)
            }
        }
        allTableView.mj_header = SwiftDiyHeader(refreshingBlock: {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_icon, eventPrame: "all")
            self.requestNetWorkDataList(sortKey: self.coinSortingKey.rawValue, offset: 0)
            
        })
        allTableView.mj_header.lastUpdatedTimeKey = "AllViewContoller"
        allTableView.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            
            if self.isShowTagWithAll == true  {
                self.requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: self.allDataArr.count, limit: 20, mj_headerRefresh: false)
            } else {
                self.requestNetworkWithCoinPair(symbol: self.currentClickCoinKey, sortKey: self.coinSortingKey.rawValue, offset: self.coinPairArr.count, mj_headerRefresh: false)
            }
            
        })
//        self.requestNetWorkDataList(sortKey: self.coinSortingKey.rawValue, offset: 0)
        allTableView.mj_header.beginRefreshing()
    }
    func loadFailedView() {
        self.allDataArr.removeAll()
        self.coinPairArr.removeAll()
        self.allTableView.reloadData()
        self.allTableView.addSubview(networkFailView)
        networkFailView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-42)
        }
    }
    
    //MARK: - Action
    @objc func refreshData(notif: NSNotification) {
        self.allTableView.reloadData()
    }
    
    @objc func screeningBtnClick() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Sorting_FloatingLayer)
        self.navigationController?.tabBarController?.view.addSubview(screeningView)
    }
    
    @objc func screeningAction(sortBtn: UIButton) {
        
        if isRequestNetwork == true { return }
        for subView in (sortBtn.superview?.subviews)! {
            if subView.isKind(of: UIButton.self) {
                let subBtn:UIButton = subView as! UIButton
                subBtn.isSelected = (subView.tag == sortBtn.tag)
            }
        }
        var sortKey:String = ""
        switch sortBtn.tag {
        case 0:
            sortKey = MarketsAllTagSortParamKey.cap_asc.rawValue
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_MarketCap_Ascending)
            
            break
        case 1:
            sortKey = MarketsAllTagSortParamKey.cap_desc.rawValue
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_MarketCap_Descending)
            
            break
        case 2:
            sortKey = MarketsAllTagSortParamKey.price_asc.rawValue
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Price_Ascending)
            
            break
        case 3:
            sortKey = MarketsAllTagSortParamKey.price_desc.rawValue
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Price_Descending)
            
            break
        default:
            break
        }
        MarketsAllTagSortSelectedKey = sortKey
        requestNetworkWithAllData(sortKey: sortKey, offset: 0, limit: 20, mj_headerRefresh: false)
        
    }
    
    func requestNetWorkDataList(sortKey: String,offset: Int) {
        if isRequestNetwork == true { return }
        
        if isShowTagWithAll == true {
            requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: offset, limit: 20, mj_headerRefresh: false)
        } else {
            self.requestNetworkWithCoinPair(symbol: currentClickCoinKey, sortKey: sortKey, offset: 0, mj_headerRefresh: false)
        }
    }
    
    func requestNetworkWithAllData(sortKey: String, offset: Int, limit: Int,mj_headerRefresh: Bool) {
        //        if mj_headerRefresh == false {
        //            self.pleaseWait()
        //        }
        self.isRequestNetwork = true
        MarketsAPIProvider.request(MarketsAPI.markets_all(sortKey, offset, limit)) { [weak self](result) in
            self?.clearAllNotice()
            self?.allTableView.mj_header.endRefreshing()
            self?.allTableView.mj_footer.endRefreshing()
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_completed_icon, eventPrame: "all")
            self?.networkFailView.removeFromSuperview()
            self?.isRequestNetwork = false
            
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                
                let json = try? JSONDecoder().decode(MarketsAllStruct.self, from: decryptedData)
                
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                if (offset != 0) && (json?.data?.count == 0) {
                    self?.allTableView.mj_footer.state = MJRefreshState.noMoreData
                    self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
                    return
                }
                DispatchQueue.main.async {
                    if offset == 0 {
                        self?.allDataArr.removeAll()
                    }
                    for symbol:MarketsAllDataStruct in (json?.data)! {
                        self?.allDataArr.append(symbol)
                    }
                    self?.allTableView.reloadData()
                    if offset == 0 && self?.allDataArr.count != 0 {
                        self?.allTableView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
                    }
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.loadFailedView()
            }
        }
    }
    
    func requestNetworkWithCoinPair(symbol: String, sortKey: String, offset: Int, mj_headerRefresh: Bool) {
        //        if mj_headerRefresh == false {
        //            self.pleaseWait()
        //        }
        self.isRequestNetwork = true
        MarketsAPIProvider.request(MarketsAPI.markets_coinPair(symbol, offset, 20, sortKey)) { [weak self](result) in
            self?.clearAllNotice()
            self?.allTableView.mj_header.endRefreshing()
            self?.allTableView.mj_footer.endRefreshing()
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_completed_icon, eventPrame: "all")
            self?.networkFailView.removeFromSuperview()
            self?.isRequestNetwork = false
            
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                
                let json = try? JSONDecoder().decode(MarketsCoinPairModel.self, from: decryptedData)
                
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                if  (offset != 0) && (json?.data?.count == 0) {
                    self?.allTableView.mj_footer.state = MJRefreshState.noMoreData
                    self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
                    return
                }
                
                DispatchQueue.main.async {
                    
                    
                    if offset == 0 {
                        self?.coinPairArr.removeAll()
                    }
                    for symbol:MarketsCoinPairDataModel in (json?.data)! {
                        self?.coinPairArr.append(symbol)
                    }
                    
                    self?.allTableView.reloadData()
                    if offset == 0 && self?.coinPairArr.count != 0{
                        self?.allTableView.scrollToRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: true)
                    }
                }
            } else {
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.loadFailedView()
            }
        }
    }
    func favoritesStateRequest(symbol: String, exchange: String, pair: String, isFavorite: Bool, arrIndex: Int) {
        MarketsAPIProvider.request(MarketsAPI.markets_currencyFavorite(symbol, exchange, pair,isFavorite)) { [weak self](result) in
            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
                
                if json?.code != 0 {
                    let msg = isFavorite ? SWLocalizedString(key: "add_failure") : SWLocalizedString(key: "cancel_failure")
                    self?.noticeOnlyText(msg)
                    print("currencyFavorite response json: \(String(describing: json ?? nil))")
                    return
                }
                if let strongSelf = self {
                    if (self?.isShowTagWithAll)! == true {
                        var symbol:MarketsAllDataStruct = strongSelf.allDataArr[arrIndex]
                        symbol.favoriteStatus = isFavorite ? 1 : 2
                        strongSelf.allDataArr.remove(at: arrIndex)
                        strongSelf.allDataArr.insert(symbol, at: arrIndex)
                    } else {
                        var symbol:MarketsCoinPairDataModel = strongSelf.coinPairArr[arrIndex]
                        symbol.favorite_status = isFavorite ? 1 : 2
                        strongSelf.coinPairArr.remove(at: arrIndex)
                        strongSelf.coinPairArr.insert(symbol, at: arrIndex)
                    }
                    
                    strongSelf.allTableView.reloadRows(at: [IndexPath.init(row: arrIndex, section: 0)], with: UITableViewRowAnimation.none)
                    
                    let msg = isFavorite ? SWLocalizedString(key: "add_success") : SWLocalizedString(key: "cancel_success")
                    strongSelf.noticeOnlyText(msg)
                }
            } else {
                
                let msg = isFavorite ? SWLocalizedString(key: "add_failure") : SWLocalizedString(key: "cancel_failure")
                self?.noticeOnlyText(msg)
            }
        }
    }
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowTagWithAll == true  {
            return allDataArr.count
        }
        return coinPairArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowTagWithAll == true  {
            let cell:AllTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AllTableViewCell") as! AllTableViewCell
            let model:MarketsAllDataStruct = self.allDataArr[indexPath.row]
            cell.fillDataWithSymbolStruct(detailStruct: model, indexPath: indexPath)
            cell.delegate_favor = self
            return cell
            
        } else {
            let cell:MarketPairCell = tableView.dequeueReusableCell(withIdentifier: "MarketPairCell") as! MarketPairCell
            cell.selectionStyle = .none
            let model :MarketsCoinPairDataModel = self.coinPairArr[indexPath.row]
            if indexPath.row < self.coinPairArr.count {
                cell.fillDataWithMarketsCoinPairDataModel(model: model, indexPath: indexPath)
            }
            cell.delegate_favor = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isShowTagWithAll == true  {
            let vc:AllDetailViewController = AllDetailViewController()
            let symbol:MarketsAllDataStruct = self.allDataArr[indexPath.row]
            vc.symbolName = symbol.symbol
            vc.symbolIconUrl = symbol.icon
            vc.hidesBottomBarWhenPushed = true
            self.delegate?.allChildDidSelect(child: self, vc: vc)
//            self.view.superview?.viewController().navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc:TransactionPairDetailViewController = TransactionPairDetailViewController()
            
            let symbol:MarketsCoinPairDataModel = self.coinPairArr[indexPath.row]
            vc.coinPair = symbol
            
            vc.reloadFavoriteStatusClosure = { (status:Int) in
                print("\(status)")
                var symbol = self.coinPairArr[indexPath.row]
                symbol.favorite_status = status
                self.coinPairArr[indexPath.row] = symbol
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
            
            
            vc.hidesBottomBarWhenPushed = true
            self.delegate?.allChildDidSelect(child: self, vc: vc)
//            self.view.superview?.viewController().navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func reloadAll() {
        self.allTagSortTitleView.removeFromSuperview()
        self.coinPairTagSortTitleView.removeFromSuperview()
        self.screeningView.removeFromSuperview()
        if self.isShowTagWithAll {
            self.screeningView.setButtonSelected()
            self.allTagSortTitleView.setSortingButton()
            self.view.addSubview(self.allTagSortTitleView)
            allTagSortTitleView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(originY)
                make.width.equalTo(SWScreen_width)
                make.height.equalTo(34)
            }
        } else {
            self.coinPairTagSortTitleView.setButtonState(sortKey: self.coinSortingKey)
            self.view.addSubview(self.coinPairTagSortTitleView)
            coinPairTagSortTitleView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(originY)
                make.width.equalTo(SWScreen_width)
                make.height.equalTo(34)
            }
        }
        self.requestNetWorkDataList(sortKey: self.coinSortingKey.rawValue, offset: 0)
    }
    
    //MARK: Cell Favorites Button delegate 添加自选
    
    func allDataFavoritesButtonAction(indexPath: IndexPath) {
        let model:MarketsAllDataStruct = self.allDataArr[indexPath.row]
        let eventName2 = model.favoriteStatus == 1 ? SWUEC_Click_CancelFavorites_All_Page : SWUEC_Click_AddFavorites_All_Page
        SPUserEventsManager.shared.addCount(forEvent: eventName2)//打点
        
        let favState = model.favoriteStatus == 1 ?  false : true
        self.favoritesStateRequest(symbol: model.symbol!, exchange: "", pair: "", isFavorite: favState, arrIndex: indexPath.row)
    }
    
    func favoritesButtonAction(indexPath: IndexPath) {
        if self.isShowTagWithAll == true {
            let model:MarketsAllDataStruct = self.allDataArr[indexPath.row]
            let eventName2 = model.favoriteStatus == 1 ? SWUEC_Click_CancelFavorites_All_Page : SWUEC_Click_AddFavorites_All_Page
            SPUserEventsManager.shared.addCount(forEvent: eventName2)//打点
            
            let favState = model.favoriteStatus == 1 ?  false : true
            self.favoritesStateRequest(symbol: model.symbol!, exchange: "", pair: "", isFavorite: favState, arrIndex: indexPath.row)
        } else {
            let model:MarketsCoinPairDataModel = self.coinPairArr[indexPath.row]
            let eventName2 = model.favorite_status == 1 ? SWUEC_Click_CancelFavorites_All_Page : SWUEC_Click_AddFavorites_All_Page
            SPUserEventsManager.shared.addCount(forEvent: eventName2)//打点
            
            let favState = model.favorite_status == 1 ?  false : true
            self.favoritesStateRequest(symbol: model.symbol!, exchange: model.exchange!, pair: model.pair!, isFavorite: favState, arrIndex: indexPath.row)
        }
        
    }
    //MARK: - dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
