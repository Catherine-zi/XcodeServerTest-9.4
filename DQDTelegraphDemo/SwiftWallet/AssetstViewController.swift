//
//  AssetstViewController.swift
//  SwiftWallet
//
//  Created by Jack on 13/03/2018.
//  Copyright © 2018 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit

@objc public class AssetstViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate{//

	private lazy var assetsTopView:AssetsTopView = {
		let topView:AssetsTopView = AssetsTopView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: assetsTopSpecialViewH))
		topView.backgroundColor = UIColor.white
		return topView
	}()
	private lazy var mainTab:UITableView = {
		let tab:UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), style: .grouped)
		tab.delegate = self
		tab.dataSource = self
		tab.register(UINib.init(nibName: "AssetsMainTableViewCell", bundle: nil), forCellReuseIdentifier: "AssetsMainTableViewCell")
		tab.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		tab.separatorStyle = .none
		tab.showsVerticalScrollIndicator = false
		return tab
	}()
	
	private var assetsTypeArr:[AssetsTokensModel] = []
	private var currentWalletCount:Int = 0
    var assetsNeedMinCellCount:Int {
        get {
            return Int(assetsNeedMinContentSize/68)
        }
    }
    var blankCellHeight: CGFloat {
        get {
            return (assetsNeedMinContentSize - 34 - CGFloat(assetsTypeArr.count * 68)) / CGFloat(assetsNeedMinCellCount)
        }
    }
    var tokenArray: [AssetsTokensModel]?
//    private var waitingWalletArray: [SwiftWalletModel] = []
	
	override public func viewDidLoad() {
		super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Assets_TabBar)//打点
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_Assets_Page)
//        loadGetTokens()
		forReloadAssetsType()
		
		setUpViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadBalance), name: SWNotificationName.getRateSuccess.notificationName, object: nil)
	}
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBalance()
    }
    
//    override public func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.navigationController?.tabBarController?.tabBar.isHidden = false
//    }

	private func forReloadAssetsType() {
		if SwiftWalletManager.shared.walletArr.count > 0 {
			if SwiftWalletManager.shared.walletArr.first?.assetsType != nil {
				assetsTypeArr = (SwiftWalletManager.shared.walletArr.first?.assetsType)!
			}
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadAssetsType), name: SWNotificationName.reloadAssetsType.notificationName, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadAssetsType), name: SWNotificationName.backWalletSucces.notificationName, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadWalletArr), name: SWNotificationName.addWalletSuccess.notificationName, object: nil)
	}
	
	@objc private func reloadAssetsType() {
		self.reloadDataSource(count: self.currentWalletCount)
	}


	private func setUpViews(){
		
		if #available(iOS 11.0, *) {
			mainTab.contentInsetAdjustmentBehavior = .never
		} else {
			self.automaticallyAdjustsScrollViewInsets = false
		}
		
		assetsTopView.headScrollView = mainTab
        self.mainTab.mj_header = SwiftDiyHeader(refreshingBlock: {
            self.loadBalance()
        })
        self.mainTab.mj_header.lastUpdatedTimeKey = "AssetViewContoller"
		self.view.addSubview(mainTab)
		self.view.addSubview(assetsTopView)
		self.view.bringSubview(toFront: assetsTopView)
		self.view.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		
		assetsTopView.scrollBlock = { [weak self](count:Int) in
			
			self?.reloadDataSource(count: count)
		}
	}
	
	private func reloadDataSource(count:Int) {
		if SwiftWalletManager.shared.walletArr.count <= count {
			//进行了删除操作
			if SwiftWalletManager.shared.walletArr.count > 0 {
				reloadDataSource(count: SwiftWalletManager.shared.walletArr.count - 1)
			}
			return
		}
		let model = SwiftWalletManager.shared.walletArr[count]
        _ = SwiftExchanger.shared.calculateTotalCost(wallet: model)
		if model.assetsType != nil {
			
            SwiftWalletManager.shared.selectedAssetWallet = model // for scan to transfer
			self.assetsTypeArr = model.assetsType!
			self.currentWalletCount = count
            self.assetsTopView.normalTopView.walletModel = SwiftWalletManager.shared.walletArr[self.currentWalletCount]
			self.mainTab.reloadData()
			
			DispatchQueue.main.async {
//                self.mainTab.contentSize = self.mainTab.contentSize.height > assetsNeedMinContentSize ? self.mainTab.contentSize : CGSize(width: self.mainTab.contentSize.width, height: assetsNeedMinContentSize)
			}

		}
	}
    
    @objc private func loadBalance () {
        let group = DispatchGroup()
        for walletModel: SwiftWalletModel in SwiftWalletManager.shared.walletArr {
            _ = SwiftExchanger.shared.calculateTotalAsset(wallet: walletModel)
            if let type = walletModel.coinType {
                switch type {
                case .BTC:
                    loadBtcCurrency(address: walletModel.extendedPublicKey!, wallet: walletModel, group: group)
                case .LTC:
                    loadLtcCurrency(address: walletModel.extendedPublicKey!, wallet: walletModel, group: group)
                case .ETH:
                    loadEthCurrency(address: walletModel.extendedPublicKey!, wallet: walletModel, group: group)
                }
            }
        }
        group.notify(queue: .main) {
            if self.mainTab.mj_header != nil {
                self.mainTab.mj_header.endRefreshing()
            }
            var AllTotaLBalance = Decimal()
            for walletModel: SwiftWalletModel in SwiftWalletManager.shared.walletArr {
                if walletModel.totalAssets != nil {
                    AllTotaLBalance += walletModel.totalAssets!
                }
            }
            SPUserEventsManager.shared.trackEventAction(SWUEC_Assets_State, eventPrame: AllTotaLBalance > 0 ? "1" : "0")
            SPUserEventsManager.shared.trackEventAction(SWUEC_Asstets_amount, eventPrame: AllTotaLBalance.description)
        }
        self.reloadDataSource(count: self.currentWalletCount)
        self.assetsTopView.specialTopView.collectionView.reloadData()
    }
    
    private func loadEthCurrency(address: String, wallet: SwiftWalletModel, group: DispatchGroup) {
        group.enter()
        EthAPIProvider.request(EthAPI.ethMutipleBalances(address, wallet.assetsType ?? [])) { [weak self](result) in
            switch result {
            case let .success(response):
                //                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(EthMultipleBalanceModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get balance error")
                    group.leave()
                    return
                }
                wallet.allAssets = json?.data
                _ = SwiftExchanger.shared.calculateTotalAsset(wallet: wallet)
                self?.reloadDataSource(count: (self?.currentWalletCount)!)
                self?.assetsTopView.specialTopView.collectionView.reloadData()
                self?.uploadWalletAssets(wallet: wallet)
                group.leave()
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                group.leave()
            }
        }
    }
    
    private func loadBtcCurrency(address: String, wallet: SwiftWalletModel, group: DispatchGroup) {
        group.enter()
        BtcAPIProvider.request(BtcAPI.btcCurrency(address)) { [weak self](result) in
            switch result {
            case let .success(response):
//                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(BtcBalanceModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get balance error")
                    group.leave()
                    return
                }
                guard let balance = json?.data.balance else {
                    group.leave()
                    return
                }
                wallet.allAssets = ["":balance]
                _ = SwiftExchanger.shared.calculateTotalAsset(wallet: wallet)
                self?.reloadDataSource(count: (self?.currentWalletCount)!)
                self?.assetsTopView.specialTopView.collectionView.reloadData()
                self?.uploadWalletAssets(wallet: wallet)
                group.leave()
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                group.leave()
            }
        }
    }
    
    private func loadLtcCurrency(address: String, wallet: SwiftWalletModel, group: DispatchGroup) {
        group.enter()
        LtcAPIProvider.request(LtcAPI.ltcCurrency(address)) { [weak self](result) in
            switch result {
            case let .success(response):
                //                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(ltcBalanceModel.self, from: response.data)
                if json?.errcode != 0 {
                    print(json?.msg ?? "get balance error")
                    group.leave()
                    return
                }
                guard let balance = json?.data.balance else {
                    group.leave()
                    return
                }
                wallet.allAssets = ["":balance]
                _ = SwiftExchanger.shared.calculateTotalAsset(wallet: wallet)
                self?.reloadDataSource(count: (self?.currentWalletCount)!)
                self?.assetsTopView.specialTopView.collectionView.reloadData()
                self?.uploadWalletAssets(wallet: wallet)
                group.leave()
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                group.leave()
            }
        }
    }
    
    private func uploadWalletAssets(wallet: SwiftWalletModel) {
        guard let totalAssets = wallet.totalAssets,
            let address = wallet.extendedPublicKey else {return}
        if totalAssets == 0 {return}
        var assetsInUsd = Decimal()
        if SwiftExchanger.shared.currency == SwiftExchanger.SwiftCurrency.Usd {
            assetsInUsd = totalAssets
        } else {
            assetsInUsd = SwiftExchanger.shared.getConvertedCurrency(amount: totalAssets, from: SwiftExchanger.shared.currency, to: SwiftExchanger.SwiftCurrency.Usd)
        }
        let isWatch = wallet.extendedPrivateKey == nil ? "1" : "2"
        AssetsAPIProvider.request(AssetsAPI.addLog(address: address, asset: assetsInUsd.description, watch: isWatch)) { (result) in
            switch result {
            case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(AssetsGetTokensModel.self, from: decryptedData)
                if json?.code != 0 {
                    print(json?.msg ?? "get balance error")
                    return
                }
            case let .failure(error):
                print("error = \(error)")
            }
        }
    }
    
//    private func reloadWaitingWalletAssets () {
//        for wallet in self.waitingWalletArray {
//            _ = SwiftExchanger.shared.calculateTotalAsset(wallet: wallet)
//        }
//        self.waitingWalletArray.removeAll()
//    }
    
//    private func loadGetTokens(){
//
//        AssetsAPIProvider.request(AssetsAPI.getTokens) { [weak self](result) in
//
//            switch result {
//            case let .success(response):
//                let decryptedData = Data.init(decryptionResponseData: response.data)
//
//                let json = try? JSONDecoder().decode(AssetsGetTokensModel.self, from: decryptedData)
//                if json?.code != 0 {
//                    print("error getTokens")
//                    return
//                }
//                self?.tokenArray = json?.data
//                SwiftExchanger.shared.tokenArray = json?.data
//                if self?.waitingWalletArray.count == 0 {
//                    return;
//                }
//                for wallet in (self?.waitingWalletArray)! {
//                    guard let total = SwiftExchanger.shared.calculateTotalAsset(wallet: wallet) else {
//                        return
//                    }
//                    wallet.totalAssets = Decimal(string: total)
//                }
//                self?.waitingWalletArray.removeAll()
//            case let .failure(error):
//                print("error = \(error)")
//            }
//
//        }
//    }

	public func numberOfSections(in tableView: UITableView) -> Int {
        return CGFloat(assetsTypeArr.count * 68 + 34) > assetsNeedMinContentSize ?
            assetsTypeArr.count :
            (assetsTypeArr.count + assetsNeedMinCellCount)
	}
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:AssetsMainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AssetsMainTableViewCell") as! AssetsMainTableViewCell
//        cell.delegate = self

		cell.selectionStyle = .none
		
		if indexPath.section < assetsTypeArr.count {
			
			let model = assetsTypeArr[indexPath.section]
			cell.model = model
            if let symbol = model.symbol,
                let all = SwiftWalletManager.shared.walletArr[self.currentWalletCount].allAssets
            {
                if let change = SwiftExchanger.shared.getChange24(symbol: symbol) {
                    cell.changeRateLbl.text = change.description + "%"
                    cell.changeRateLbl.textColor = change < 0 ? GainsDownColor : GainsUpColor
                    cell.changeAmountLbl.textColor = change < 0 ? GainsDownColor : GainsUpColor
                } else {
                    cell.changeRateLbl.text = "--"
                    cell.changeRateLbl.textColor = UIColor.init(hexColor: "333333")
                    cell.changeAmountLbl.textColor = UIColor.init(hexColor: "333333")
                }
                let str = SwiftExchanger.shared.getRoundedNumber(number: SwiftExchanger.shared.calculateSingleProfit(asset: model, all: all), decimalCount: 2) .description
                cell.changeAmountLbl.text = SwiftExchanger.shared.getSignumMovedCurrencySymbolString(string: str)
            }
            let backColor = indexPath.section % 2 == 0 ? UIColor.white : UIColor.init(hexColor: "f2f2f2")
            cell.backView.backgroundColor = backColor
            
            if indexPath.section != 0 {
                
                let button: MGSwipeButton = MGSwipeButton.init(title: SWLocalizedString(key: "delete_favorite"), icon: UIImage.init(named: "markets_delete_white"), backgroundColor: UIColor.init(hexColor: "F96C6C"), insets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)) { [weak self](cell) -> Bool in
                    
                    let model = SwiftWalletManager.shared.walletArr[(self?.currentWalletCount)!]
                    if model.assetsType != nil {
                        
                        self?.assetsTypeArr.remove(at: indexPath.section)
                        model.assetsType?.remove(at: indexPath.section)
                        SwiftWalletManager.shared.walletArr[(self?.currentWalletCount)!] = model
                        let suc = SwiftWalletManager.shared.storeWalletArr()
                        if suc {
                            self?.mainTab.reloadData()
                            
                            DispatchQueue.main.async {
                                if self?.mainTab != nil {
//                                                                    self?.mainTab.contentSize = (self?.mainTab.contentSize.height)! > assetsNeedMinContentSize ? (self?.mainTab.contentSize)! : CGSize(width: (self?.mainTab.contentSize.width)!, height: assetsNeedMinContentSize)
                                }
                            }
                            
                        }
                    }
                    
                    return false
                }
                button.buttonWidth = 80
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                button.centerIconOverText()
                cell.rightButtons = [button]
                cell.rightSwipeSettings.transition = .clipCenter
            }
		
            return cell
			
        } else {
            let blankCell = UITableViewCell()
            blankCell.selectionStyle = .none
            blankCell.backgroundColor = .clear
            return blankCell
        }
		
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < assetsTypeArr.count {
            let createWalletV = AssetsDetailsViewController.init(nibName: "AssetsDetailsViewController", bundle: nil)
            createWalletV.walletModel = SwiftWalletManager.shared.walletArr[self.currentWalletCount]
            createWalletV.assetIndexForInit = indexPath.section
            createWalletV.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(createWalletV, animated: true)
        }
	}

	//cell delegate
	func swipeTableCellWillEndSwiping(_ cell: MGSwipeTableCell) {
		
		
	}
	//swipecell Delegate
//	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//		if Int(orientation.rawValue) != 1 {
//			return nil
//		}
//		if indexPath.section == 0 {
//			return nil
//		}
//		let delete = SwipeAction.init(style: .destructive, title: SWLocalizedString(key: "delete_favorite")) { [weak self](action, indexPath) in
//			print("indexP = \(indexPath)")
//
//			let model = SwiftWalletManager.shared.walletArr[(self?.currentWalletCount)!]
//			if model.assetsType != nil {
//
//				self?.assetsTypeArr.remove(at: indexPath.section)
//				model.assetsType?.remove(at: indexPath.section)
//				SwiftWalletManager.shared.walletArr[(self?.currentWalletCount)!] = model
//				let suc = SwiftWalletManager.shared.storeWalletArr()
//				if suc {
//					self?.mainTab.reloadData()
//					if self?.mainTab != nil {
//						self?.mainTab.contentSize = (self?.mainTab.contentSize.height)! > assetsNeedMinContentSize ? (self?.mainTab.contentSize)! : CGSize(width: (self?.mainTab.contentSize.width)!, height: assetsNeedMinContentSize)
//					}
//
//				}
//			}
//		}
//		delete.backgroundColor = UIColor.init(red: 249.0, green: 108.0, blue: 108.0)
//		delete.image = UIImage.init(named: "markets_delete_white")
//		return [delete]
//	}
	
	//UITableViewDelegate & Datasource
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < assetsTypeArr.count {
            return 68
        } else {
            return blankCellHeight
        }
	}
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 34 : 0
	}
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if let header = Bundle.main.loadNibNamed("AssetTitleHeaderCell", owner: nil, options: [:])?.first as? AssetTitleHeaderCell {
                header.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 34)
                return header
            }
        }
		let headV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 16))
		headV.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		return headV
	}
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.0
	}
	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: 0.0))
		footerV.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		return footerV
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	public override var shouldAutorotate: Bool
	{

		return false
	}
	
	public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
}


