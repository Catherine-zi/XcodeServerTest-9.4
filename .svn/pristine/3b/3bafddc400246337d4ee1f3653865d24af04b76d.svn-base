//
//  AllViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/8.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

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


class AllViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AllDataFavoritesButtonActionDelegate, FavoritesButtonActionDelegate {//
    
    //MARK: -   Declaration attributes

    private var pairDic: Dictionary<String, [String]>?
    private var pairTagList:[String]?
    private var moreTagList:[String]?

    private var allDataArr:[MarketsAllDataStruct] = []
    private var coinPairArr:[MarketsCoinPairDataModel] = []
    
    private var currentClickCoinKey = "All"
    private var isShowTagWithAll : Bool {
        return currentClickCoinKey == "All" ? true : false
    }


    let header = MJRefreshNormalHeader()
    
    private var scrollHeaderView:MarketTitleHeaderView {
        
        let scrollHeader: MarketTitleHeaderView = MarketTitleHeaderView.init(frame: CGRect.init(x: 0, y: 0, width:  SWScreen_width, height: 35))
        scrollHeader.loadView(titles: self.pairTagList!, itemWidth: 50)
        currentClickCoinKey = self.pairTagList!.first!

        scrollHeader.itemSelectedActionBlock = { [weak self ](btnTag) in
         
            self?.allTagSortTitleView.removeFromSuperview()
            self?.coinPairTagSortTitleView.removeFromSuperview()
            
            self?.currentClickCoinKey = (self?.pairTagList![btnTag-100])!
            
            if self?.isShowTagWithAll == true {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_All_Coins_HomePage)

                self?.view.addSubview((self?.allTagSortTitleView)!)
                self?.allTagSortTitleView.snp.makeConstraints { (make) in
                    make.left.equalTo(0)
                    make.top.equalTo(35)
                    make.width.equalTo(SWScreen_width)
                    make.height.equalTo(34)
                }
                self?.requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: 0, limit: 20, mj_headerRefresh: false)
            } else {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ETH_Pairs_HomePage)

                self?.view.addSubview((self?.coinPairTagSortTitleView)!)
                self?.coinPairTagSortTitleView.snp.makeConstraints { (make) in
                    make.left.equalTo(0)
                    make.top.equalTo(35)
                    make.width.equalTo(SWScreen_width)
                    make.height.equalTo(34)
                }
                self?.requestNetworkWithCoinPair(symbol: (self?.currentClickCoinKey)!, sortKey: MarketsCoinPairsSortParamSelectedKey, offset: 0, mj_headerRefresh: false)
            }
        }
        scrollHeader.addBtn.addTarget(self, action: #selector(addButtonAction(addBtn:)), for: .touchUpInside)

        return scrollHeader
    }
    private let originY: CGFloat = 35.0

    private lazy var allTagSortTitleView : AllHeaderView = {
        let headView : AllHeaderView = Bundle.main.loadNibNamed("AllHeaderView", owner: nil, options: nil)?.last as! AllHeaderView
        headView.frame = CGRect.init(x: 0, y: originY, width: SWScreen_width, height: 34)
        headView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_down"), for: .normal)

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
    private lazy var coinPairTagSortTitleView : UIView = {
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

            self?.requestNetworkWithCoinPair(symbol: (self?.currentClickCoinKey)!, sortKey: sortKey, offset: 0, mj_headerRefresh: false)

        }
        return headView
    }()
//    private var tagSortTitleView: UIView {
//        return isShowTagWithAll == true ? allTagSortTitleView : coinPairTagSortTitleView
//    }
    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        failView.tryButton.addTarget(self, action: #selector(touchTryAgain), for: .touchUpInside)

        return failView
    }()
    
    private lazy var allTableView:UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: originY+34, width: SWScreen_width, height: SWScreen_height-SafeAreaTopHeight-34-49), style: .plain)
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
        view.addSubview(allTableView)
        view.backgroundColor = UIColor.init(hexColor: "F8F8F8")

        getCoinPairTagList()

        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_All_Page)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Coins_HomePage)

        NotificationCenter.default.addObserver(self, selector: #selector(refreshData(notif:)), name: SWNotificationName.gainsColor.notificationName, object: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Load subview
    private func getCoinPairTagList() {
        if let tagArrayArray = UserDefaults.standard.value(forKey: marketTagKeyPrefix + "pair") as? [[String]] {
            if tagArrayArray.count == 2 {
                self.pairTagList = tagArrayArray[0]
                self.moreTagList = tagArrayArray[1]
            }
        }
        requestPairTagList()
    }
    
    func loadDataView()  {
        if pairTagList?.count == 0 {
            loadFailedView()
            return
        }
        
        view.addSubview(scrollHeaderView)
        view.addSubview(allTagSortTitleView)
        allTagSortTitleView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(originY)
            make.width.equalTo(SWScreen_width)
            make.height.equalTo(34)
        }
        allTableView.mj_header = SwiftDiyHeader(refreshingBlock: {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_icon, eventPrame: "all")
            self.requestNetWorkDataList(sortKey: MarketsCoinPairsSortParamSelectedKey, offset: 0)

        })
        allTableView.mj_header.lastUpdatedTimeKey = "AllViewContoller"
        allTableView.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {

            if self.isShowTagWithAll == true  {
                self.requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: self.allDataArr.count, limit: 20, mj_headerRefresh: false)
            } else {
                self.requestNetworkWithCoinPair(symbol: self.currentClickCoinKey, sortKey: MarketsCoinPairsSortParamSelectedKey, offset: self.coinPairArr.count, mj_headerRefresh: false)
            }

        })
        self.requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: 0, limit: 20, mj_headerRefresh: false)

//        self.requestNetworkWithCoinPair(symbol: self.currentClickCoinKey, sortKey: MarketsCoinPairsSortParamSelectedKey, offset: 0, mj_headerRefresh: false)
    }
    
    func loadFailedView() {
        //        self.allTableView?.frame
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
    @objc func touchTryAgain() {
        getCoinPairTagList()

    }

    @objc func refreshData(notif: NSNotification) {
        self.allTableView.reloadData()
    }
    
    @objc func addButtonAction(addBtn: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ManageTag_Pairs_HomePage)

        let customVC : TagManageViewController = TagManageViewController()
        customVC.type = MarketTagType.pair
        for tag in pairTagList! {
            customVC.myTagArray.append(tag)
        }
        if moreTagList != nil {
            for tag in moreTagList! {
                customVC.moreTagArray.append(tag)
            }
        }
        customVC.hidesBottomBarWhenPushed = true
        customVC.reloadHeadTagBlock = { [weak self] (pairTagList, moreList) in
            self?.pairTagList = pairTagList
            self?.moreTagList = moreList
            self?.currentClickCoinKey = (self?.pairTagList?.first)!

            self?.scrollHeaderView.removeFromSuperview()
            self?.view.addSubview((self?.scrollHeaderView)!)
            self?.requestNetworkWithAllData(sortKey: MarketsAllTagSortSelectedKey, offset: 0, limit: 20, mj_headerRefresh: false)

        }
        navigationController?.pushViewController(customVC, animated: true)
    }
    
    @objc func screeningBtnClick() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Sorting_FloatingLayer)

        let screeningView: ScreeningPopView = Bundle.main.loadNibNamed("ScreeningPopView", owner: self, options: nil)?.first as! ScreeningPopView
        screeningView.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: SWScreen_height)
        screeningView.selectedKey = MarketsAllTagSortSelectedKey
        screeningView.ScreeningButtonActionBlock = { [weak self] (button) in
            self?.screeningAction(sortBtn: button)
            if MarketsAllTagSortSelectedKey == MarketsAllTagSortParamKey.cap_desc.rawValue || MarketsAllTagSortSelectedKey == MarketsAllTagSortParamKey.price_desc.rawValue  {
                self?.allTagSortTitleView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_down"), for: .normal)
            } else {
                self?.allTagSortTitleView.nameBtn.setImage(#imageLiteral(resourceName: "markets_all_coin_sorting_up"), for: .normal)

            }
        }
        self.view.addSubview(screeningView)
        
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
   

    //MARK: - Request Network
    func requestPairTagList() {
        MarketsAPIProvider.request(MarketsAPI.markets_pairsTags) { [weak self](result) in
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsTitleTagsStruct.self, from: decryptedData)
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                if json?.data == nil { return }
                let newPairDic = json?.data
                let newPairTags:[String] = (newPairDic?["pair"])!
                let newMoreTags:[String] = (newPairDic?["more_tags"])!

                //每次对比接口与本地是否有新增tag
                let tagCount = self?.pairTagList != nil ? self?.pairTagList?.count : 0
                let moreTagCount = self?.moreTagList != nil ? self?.moreTagList?.count : 0
                
                if (tagCount == 0) && (moreTagCount == 0) {
                    self?.pairTagList = newPairTags
                    self?.moreTagList = newMoreTags

                } else if (newPairTags.count + newMoreTags.count) != (tagCount! + moreTagCount!) {
                    
                    for tag in newPairTags {
                        if (self?.pairTagList?.contains(tag))! || (self?.moreTagList?.contains(tag))! {
                            continue
                        } else {
                            self?.pairTagList?.append(tag)
                        }
                    }
                    for tag in newMoreTags {
                        if (self?.pairTagList?.contains(tag))! || (self?.moreTagList?.contains(tag))! {
                            continue
                        } else {
                            self?.moreTagList?.append(tag)
                        }
                    }
                }
                
                DispatchQueue.main.async {
//                    self?.pairDic = json?.data
//
//                    let pairTags:[String]? = self?.pairDic!["pair"]
//                    if pairTags != nil && pairTags?.count != 0 {
//                        self?.pairTagList = pairTags
//                    }
//
//                    let moreTags:[String]? = self?.pairDic!["more_tags"]
//                    if moreTags != nil && moreTags?.count != 0 {
//                        self?.moreTagList = moreTags
//                    }
                    self?.loadDataView()
                }
            } else {
//                print(result)
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))

                self?.loadFailedView()
            }
        }
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
                
                DispatchQueue.main.async {
                    if offset == 0 {
                        self?.allDataArr.removeAll()
                    }
                    
                    if offset != 0 && json?.data?.count == 0 {
                        self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
                    }
                
                    for symbol:MarketsAllDataStruct in (json?.data)! {
                        self?.allDataArr.append(symbol)
                    }
                    self?.allTableView.reloadData()
                    
                    if offset == 0 && self?.allDataArr.count != 0 {
                        self?.allTableView.scrollToRow(at: NSIndexPath.init(row: 0, section: 0) as IndexPath, at: UITableViewScrollPosition.top, animated: true)
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
            //            self?.allTableView?.isHidden = false
            self?.isRequestNetwork = false
            
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                
                let json = try? JSONDecoder().decode(MarketsCoinPairModel.self, from: decryptedData)
                
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                if offset != 0 && json?.data?.count == 0 {
                    self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
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
            self.navigationController?.pushViewController(vc, animated: true)
            
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
            self.navigationController?.pushViewController(vc, animated: true)
        }
	}
    
    //MARK: Cell Favorites Button delegate
//    func swipeTableCellWillEndSwiping(_ cell: MGSwipeTableCell) {
//        let indexPath = self.allTableView.indexPath(for: cell)
//        if indexPath == nil {
//            return
//        }
//        if isShowTagWithAll == true {
//            let symbol:MarketsAllDataStruct = self.allDataArr[indexPath!.row]
//            let eventName = symbol.favoriteStatus == 1 ? SWUEC_Show_AddFavorites_All_Page : SWUEC_Show_CancelFavorites_All_Page
//            SPUserEventsManager.shared.addCount(forEvent: eventName)
//
//        } else {
//            let symbol:MarketsCoinPairDataModel = self.coinPairArr[indexPath!.row]
//            let eventName = symbol.favorite_status == 1 ? SWUEC_Show_AddFavorites_Pairs_HomePage : SWUEC_Show_CancelFavorites_Pairs_HomePage
//            SPUserEventsManager.shared.addCount(forEvent: eventName)
//        }
//    }
    func allDataFavoritesButtonAction(indexPath: IndexPath) {
        let model:MarketsAllDataStruct = self.allDataArr[indexPath.row]
        let eventName2 = model.favoriteStatus == 1 ? SWUEC_Click_CancelFavorites_All_Page : SWUEC_Click_AddFavorites_All_Page
        SPUserEventsManager.shared.addCount(forEvent: eventName2)//打点
        
        let favState = model.favoriteStatus == 1 ?  false : true
        self.favoritesStateRequest(symbol: model.symbol!, exchange: "", pair: "", isFavorite: favState, arrIndex: indexPath.row)
    }

    func favoritesButtonAction(indexPath: IndexPath) {
        let model:MarketsCoinPairDataModel = self.coinPairArr[indexPath.row]
        let eventName2 = model.favorite_status == 1 ? SWUEC_Click_CancelFavorites_All_Page : SWUEC_Click_AddFavorites_All_Page
        SPUserEventsManager.shared.addCount(forEvent: eventName2)//打点
        
        let favState = model.favorite_status == 1 ?  false : true
        self.favoritesStateRequest(symbol: model.symbol!, exchange: "", pair: "", isFavorite: favState, arrIndex: indexPath.row)
    }
     //MARK: - dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
