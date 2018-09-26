//
//  FavoritesViewController.swift
//  SwiftWallet
//
//  Created by Selin on 2018/4/8.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import PKHUD

class FavoritesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: -
    private var sortingKey: String?

    private var timer: Timer!
    private var favoriteDataArr:[MarketsFavoritesDetailStruct] = []
    private var referenceLastPercentArr:[String] = []
    private var tmpPercentArr:[String] = []

    private var referenceLastDataArr:[MarketsFavoritesDetailStruct] = []

    private let originY: CGFloat = 0.0
    private lazy var headerView : AllHeaderView = {
        let headView : AllHeaderView = Bundle.main.loadNibNamed("AllHeaderView", owner: nil, options: nil)?.last as! AllHeaderView
        headView.frame = CGRect.init(x: 0, y: originY, width: SWScreen_width, height: 34)
        headView.nameBtn.isUserInteractionEnabled = false
        headView.volSortingBtn.setTitle(SWLocalizedString(key: "price"), for: .normal)
        headView.SelectedItemBlock = { [weak self] (btnTag, sortKey) in
            self?.sortingKey = sortKey
            if btnTag == 1 {
                self?.volSortingBtnClick(sortKey: sortKey)
            } else if btnTag == 2 {
                self?.changeSortingBtnClick(sortKey: sortKey)
            }
        }
        return headView
    }()
    
    private lazy var footerView:UIView = {
        let footerView : FavoritesAddBtnView = Bundle.main.loadNibNamed("FavoritesAddBtnView", owner: nil, options: nil)?.first as! FavoritesAddBtnView
        footerView.frame = CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 160)
        return footerView
    }()
    
    private lazy var tableView:UITableView = {
        var space:CGFloat = 34
        if SWScreen_height == 812 {
            space = 28
        }
        let tab:UITableView = UITableView.init(frame: CGRect.init(x: 0, y: originY+34, width: SWScreen_width, height: SWScreen_height-SafeAreaTopHeight-space-34-49), style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.register(UINib.init(nibName: "FavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoritesTableViewCell")
        tab.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        tab.separatorStyle = .none
        tab.rowHeight = 60
        tab.tableFooterView = footerView
        return tab
    }()
    
    private lazy var networkFailView: UIView = {
        let failView : NetworkFailView = Bundle.main.loadNibNamed("NetworkFailView", owner: nil, options: nil)?.first as! NetworkFailView
        failView.tryButton.addTarget(self, action: #selector(touchTryAgain), for: .touchUpInside)
        failView.tipsLabel.text = SWLocalizedString(key: "load_failed")

        return failView
    }()
    var pageNum : Int = 0
    var isFirstInstallApp :Bool {
        
//      return  TelegramUserInfo.shareInstance.telegramLoginState == "yes" ? false : true
       let isFirst = UserDefaults.standard.object(forKey: "isFirstInstallApp")
        if isFirst == nil {
            UserDefaults.standard.set(false, forKey: "isFirstInstallApp")
            return true
        }
        return false
	}
    
     //MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Favotites_Page)//打点
        view.backgroundColor = UIColor.init(hexColor: "F8F8F8")
        view.addSubview(headerView)
        view.addSubview(tableView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(34)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.left.right.equalTo(0)
        }

        tableView.mj_header = SwiftDiyHeader(refreshingBlock: {
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_icon, eventPrame: "favorite")
            self.pageNum = 0
            self.requestNetworkWithFavoriteCoins(pageNo: self.pageNum, isAutoRefresh: false)
        })
		tableView.mj_header.lastUpdatedTimeKey = "FavoritesViewContoller"
        tableView.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            self.pageNum = self.favoriteDataArr.count
            self.requestNetworkWithFavoriteCoins(pageNo:self.pageNum, isAutoRefresh: false)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstInstallApp == true {
            requestNetworkAllDataFirstFive()
        } else {
            tableView.mj_header.beginRefreshing()
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(aotuRefreshData), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if timer != nil {
            timer.invalidate()//此页面不显示时销毁计时器
            timer = nil
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     //MARK: -  Action
    @objc func touchTryAgain() {
        if isFirstInstallApp == true {
            requestNetworkAllDataFirstFive()
        } else {
            requestNetworkWithFavoriteCoins(pageNo: 0, isAutoRefresh: false)
        }
    }
    
    @objc open func aotuRefreshData() {
//        if isFirstInstallApp == true {
//            return
//        }
        requestNetworkWithFavoriteCoins(pageNo: pageNum, isAutoRefresh: true)
    }
  
    func changeSortingBtnClick(sortKey: String) {
        
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Change_Sorting)
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Change_Sorting_Favorites_Page)
        
        for (i, model_i) in favoriteDataArr.enumerated() {
            if i==0 {
                print(model_i)//随意打印，消除警告
            }
            for (k, model_k) in favoriteDataArr.enumerated() {
                if k == favoriteDataArr.count-1 { continue }
                let model_k2 = favoriteDataArr[k+1]
                
                let change_k = Float(model_k.percentChange24h!)!
                let change_k2 = Float(model_k2.percentChange24h!)!
                if sortKey == MarketsAllTagSortParamKey.ch_desc.rawValue {
                    if change_k < change_k2 {
                        let temp = favoriteDataArr[k]
                        favoriteDataArr[k] = favoriteDataArr[k+1]
                        favoriteDataArr[k+1] = temp
                    }
                } else if sortKey == MarketsAllTagSortParamKey.ch_asc.rawValue  {
                    if change_k > change_k2 {
                        let temp = favoriteDataArr[k]
                        favoriteDataArr[k] = favoriteDataArr[k+1]
                        favoriteDataArr[k+1] = temp
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func volSortingBtnClick(sortKey: String) {
        
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Price_Sorting_Favorites_Page)
      
        for (i, model_i) in favoriteDataArr.enumerated() {
            if i==0 {
                print(model_i)//随意打印，消除警告
            }
            for (k, model_k) in favoriteDataArr.enumerated() {
                if k == favoriteDataArr.count-1 { continue }

                let model_k2 = favoriteDataArr[k+1]
                let price_k = Float(model_k.priceUSD!)!
                let price_k2 = Float(model_k2.priceUSD!)!
                if sortKey == MarketsAllTagSortParamKey.vo_desc.rawValue {
                    if price_k < price_k2 {
                        let temp = favoriteDataArr[k]
                        favoriteDataArr[k] = favoriteDataArr[k+1]
                        favoriteDataArr[k+1] = temp
                    }
                } else if sortKey == MarketsAllTagSortParamKey.vo_asc.rawValue  {
                    if price_k > price_k2 {
                        let temp = favoriteDataArr[k]
                        favoriteDataArr[k] = favoriteDataArr[k+1]
                        favoriteDataArr[k+1] = temp
                    }
                }
            }
        }
        self.tableView.reloadData()
        
    }
    
    //MARK: - load subview
    func loadFailedView() {
//        self.tableView.isHidden = true
        self.favoriteDataArr.removeAll()
        self.tableView.reloadData()
        self.tableView.addSubview(networkFailView)
        networkFailView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-17)
        }
    }
   
    //MARK: - RequestNetwork
    func requestNetworkFirstOpenApp()  {
        MarketsAPIProvider.request(MarketsAPI.markets_setDefaultCurrencyFavorite) {  [weak self] (result) in
            
            if case let .success(response) = result {
                SPUserEventsManager.shared.trackEventAction(SWUEC_Show_Refresh_completed_icon, eventPrame: "favorite")

                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                if decryptedData.count == 0 {
                    print("decryptedData is nil")
                    return
                }
                let json = try? JSONDecoder().decode(MarketsAllStruct.self, from: decryptedData)
                
                if json?.code != 0 {
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                self?.requestNetworkWithFavoriteCoins(pageNo: 0, isAutoRefresh: false)

            }
        }
    }
    func requestNetworkAllDataFirstFive() {
        MarketsAPIProvider.request(MarketsAPI.markets_all(MarketsAllTagSortParamKey.cap_desc.rawValue, 0, 5)) { [weak self](result) in
            self?.clearAllNotice()
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            self?.networkFailView.removeFromSuperview()
            
            if case let .success(response) = result {
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsAllStruct.self, from: decryptedData)
                
                if json?.code != 0 {
                    self?.loadFailedView()
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.favoriteDataArr.removeAll()

                    for structModel:MarketsAllDataStruct in (json?.data)! {
                        var model: MarketsFavoritesDetailStruct = MarketsFavoritesDetailStruct()
                        model.symbol = structModel.symbol
                        model.icon = structModel.icon
                        model.priceUSD = structModel.priceUsd
                        model.percentChange24h  = structModel.percentChange24h
                        model.exchange = ""
                        model.pair = ""
                        model.pairRightPrice = ""
                        self?.favoriteDataArr.append(model)
                        self?.favoritesRequest(symbol: model.symbol!, exchange: "", pair: "", isFavorite: true)
                    }
                    self?.tableView.reloadData()

                }
            } else {
//                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.loadFailedView()
            }
        }
    }
    
    func requestNetworkWithFavoriteCoins(pageNo:Int, isAutoRefresh: Bool) {
       
        self.referenceLastPercentArr.removeAll()
        for model in self.favoriteDataArr {
            let tmpModel : MarketsFavoritesDetailStruct = model
            self.referenceLastPercentArr.append(tmpModel.percentChange24h!)
        }
      
        MarketsAPIProvider.request(MarketsAPI.markets_favorites(pageNo, 20)) { [weak self](result) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            self?.networkFailView.removeFromSuperview()
            

            if case let .success(response) = result {
                let decryptedData = Data.init(decryptionResponseData: response.data)
                if let json = try? JSONDecoder().decode(MarketsFavoritesStruct.self, from: decryptedData) {
                    if json.code != 0 {
                        self?.loadFailedView()
                        print("favorite response json: \(String(describing: json ))")
                        return
                    }
                    if (pageNo != 0) && (json.data?.count == 0) && (isAutoRefresh == false) {
                        self?.tableView.mj_footer.state = MJRefreshState.noMoreData
//                        self?.noticeOnlyText(SWLocalizedString(key: "load_end"))
                        return
                    }
                    DispatchQueue.main.async {
                        if pageNo == 0 {
							self?.tableView.mj_footer.state = MJRefreshState.idle
                            self?.favoriteDataArr.removeAll()
                        }
						if json.data != nil {
							for symbol:MarketsFavoritesDetailStruct in (json.data)! {
								self?.favoriteDataArr.append(symbol)
							}
						}
						
                        if json.data?.count == 0 {
                            self?.tableView.mj_footer.state = MJRefreshState.noMoreData
                        }
                        if self?.headerView.volSortingBtn.isSelected == true {
                            self?.volSortingBtnClick(sortKey: (self?.sortingKey)!)
                        } else if (self?.headerView.changeSortingBtn.isSelected == true) {
                            self?.changeSortingBtnClick(sortKey: (self?.sortingKey)!)
                        } else {
                            self?.tableView.reloadData()
                        }
                    }
                }
            } else {
//                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                self?.loadFailedView()
            }
        }
    }
    //     favorites
    func favoritesRequest(symbol: String, exchange: String, pair: String, isFavorite: Bool ) {
        MarketsAPIProvider.request(MarketsAPI.markets_currencyFavorite(symbol, exchange, pair, isFavorite)) { (result) in
            if case let .success(response) = result {
                
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
                
                if isFavorite == true { return }
                
                if json?.code != 0 {
                    self.noticeOnlyText(SWLocalizedString(key: "cancel_failure"))
                    print("currencyFavorite response json: \(String(describing: json ?? nil))")
                    return
                }
//                self.favoriteDataArr.remove(at: (indexPath?.row)!)
//                self.tableView.reloadData()

                self.noticeOnlyText(SWLocalizedString(key: "cancel_success"))
            }else {
                self.noticeOnlyText(SWLocalizedString(key: "cancel_failure"))
            }
        }
    }
    //MARK: - tableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell:FavoritesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FavoritesTableViewCell") as! FavoritesTableViewCell
        if indexPath.row >= self.favoriteDataArr.count {
            return cell
        }
        let model :MarketsFavoritesDetailStruct = self.favoriteDataArr[indexPath.row]
        
        cell.fillDataWithDetailStruct(model: model, indexPath: indexPath)
        //涨幅动画
        if indexPath.row < referenceLastPercentArr.count {
            let lastPercent = referenceLastPercentArr[indexPath.row]
            if model.percentChange24h != lastPercent {
                let animationIMGV = UIImageView.init(image: #imageLiteral(resourceName: "percent_animationImage"))
                animationIMGV.frame = CGRect.init(x: -30, y: 0, width: 32, height: 26)
                cell.changeLabel.addSubview(animationIMGV)
                
                UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                    animationIMGV.frame = CGRect.init(x: cell.changeLabel.frame.size.width, y: 0, width: 32, height: 26)
                }) { (completed) in
                    animationIMGV.removeFromSuperview()
                }
            }
        }
        //长按cell回调
        cell.longPressActionBlock = { [weak self] in
            
            let alertVC : UIAlertController = UIAlertController.init()
            let deleteAction : UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "delete_favorite"), style: UIAlertActionStyle.destructive, handler: { [weak self](action) in
                
                self?.favoritesRequest(symbol: model.symbol!, exchange: model.exchange!, pair:model.pair!, isFavorite: false)
                
                self?.favoriteDataArr.remove(at: indexPath.row)
                self?.tableView.reloadData()
                
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Delete_Favorites_Page)//打点
            })
            let cancelAction: UIAlertAction = UIAlertAction.init(title: SWLocalizedString(key: "log_out_bitPub_dialog_cancel"), style: .cancel, handler: nil)
            alertVC.addAction(deleteAction)
            alertVC.addAction(cancelAction)
            self?.present(alertVC, animated: true, completion: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row >= self.favoriteDataArr.count {
			return
		}
        let detailStruct :MarketsFavoritesDetailStruct = self.favoriteDataArr[indexPath.row]
       //交易对详情
        if detailStruct.pair?.count != 0  {
            let vc:TransactionPairDetailViewController = TransactionPairDetailViewController()
            var model : MarketsCoinPairDataModel = MarketsCoinPairDataModel()
            model.symbol = detailStruct.symbol
            model.pair = detailStruct.pair
            model.icon = detailStruct.icon
            model.exchange = detailStruct.exchange
            model.favorite_status = 1
            model.price_usd = detailStruct.priceUSD
            vc.coinPair = model
            vc.hidesBottomBarWhenPushed = true
//            vc.reloadFavoriteStatusClosure = { (status:Int) in
//                if status != 1 {//delete
//                    self.favoriteDataArr.remove(at: indexPath.row)
//                }
//            }
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {//货币详情
            let vc:AllDetailViewController = AllDetailViewController()
            vc.symbolName = detailStruct.symbol
            vc.symbolIconUrl = detailStruct.icon
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
           
        }
    }
   
}
