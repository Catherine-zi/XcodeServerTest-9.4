//
//  ManageWalletViewController.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/6.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import EthereumKit

class ManageWalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var importBtn: UIButton!
    @IBOutlet weak var watchBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLbl: UILabel!
    var walletArr:[SwiftWalletModel] = []
    var balanceArr:[String:[String:String]] = [:]
//    var walletBackImageNameArr:[String] = []
//    lazy var refreshHeader:WalletRefreshControl = {
//        let header = WalletRefreshControl()
//        header.scrollView = self.tableView
//        header.refreshBlock = self.refresh
//        return header
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_ManageWallets_page)

        setUpViews();
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: SWNotificationName.backWalletSucces.notificationName, object: nil)
    }
	
	@objc func reloadData() {
		self.tableView.reloadData()
	}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContent();
//        loadEthCurrency(address: "0x00360d2b7d240ec0643b6d819ba81a09e40e5bcd")
    }
    
    func setUpViews() {
        self.navtitleLabel.text = SWLocalizedString(key: "manage_wallets")
        self.createBtn.setTitle(SWLocalizedString(key: "wallet_create"), for: .normal)
        self.importBtn.setTitle(SWLocalizedString(key: "wallet_import"), for: .normal)
        self.watchBtn.setTitle(SWLocalizedString(key: "wallet_watch"), for: .normal)
        self.emptyLbl.text = SWLocalizedString(key: "no_wallet")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "ManageWalletCell", bundle: nil), forCellReuseIdentifier: "manageWalletCell")
        
//        self.tableView.addSubview(self.refreshHeader)
        self.createBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 20)
        self.importBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 20)
        self.watchBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 20)
    }
    
    func setContent() {
        let arr: [SwiftWalletModel] = SwiftWalletManager.shared.walletArr
        if arr.count > 0 {
            self.emptyView.isHidden = true
            SPUserEventsManager.shared.trackEventAction(SWUEC_Show_WalletList, eventPrame: "1")
        } else {
            self.emptyView.isHidden = false
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_NoManageWallets_page)
            if self.walletArr.count > 0 {
                SPUserEventsManager.shared.trackEventAction(SWUEC_Show_WalletList, eventPrame: "0")
            } else {
                SPUserEventsManager.shared.trackEventAction(SWUEC_Show_WalletList, eventPrame: "2")
            }
        }
        
//        if self.walletArr.count != arr.count {
//            walletBackImageNameArr = CreateRandomColorForWallet.getRandomColorForWallet(randomCount: arr.count)
//        }
        self.walletArr = arr
        self.tableView.reloadData()
//        self.refreshHeader.perform(#selector(self.refreshHeader.endRefreshing), with: nil, afterDelay: 1)
        let group = DispatchGroup()
        for walletModel: SwiftWalletModel in self.walletArr {
            if walletModel.extendedPrivateKey == nil || walletModel.extendedPublicKey == nil {
                break
            }
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
            self.updateLocalAddressAndBalance(key: walletModel.extendedPrivateKey!, balance: "--", address: walletModel.extendedPrivateKey!)
        }
        group.notify(queue: .main) {
            if self.tableView.mj_header != nil {
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.reloadData()
        }
    }
    
//    private func loadEthCurrency(address: String, key: String) {
//        EthAPIProvider.request(EthAPI.ethCurrency(address)) { [weak self](result) in
//            switch result {
//            case let .success(response):
////                let decryptedData = Data.init(decryptionResponseData: response.data)
//                let json = try? JSONDecoder().decode(EthBalanceModel.self, from: response.data)
//                if json?.errcode != 0 {
//                    print(json?.msg ?? "get balance error")
//                    return
//                }
//                if let amount = json?.data.amount,
//                let wei = Wei.init(amount),
//                let ether =  try? Converter.toEther(wei: wei) {
//                    self?.updateLocalAddressAndBalance(key: key, balance: ether.description, address: address)
//                }
//                self?.tableView.reloadData()
//            case let .failure(error):
//                print("error = \(error)")
//                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
//            }
//        }
//    }
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
                group.leave()
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                group.leave()
            }
        }
    }
    
//    private func loadBtcCurrency(address: String, key: String) {
//        BtcAPIProvider.request(BtcAPI.btcCurrency(address)) { [weak self](result) in
//            switch result {
//            case let .success(response):
//                //                let decryptedData = Data.init(decryptionResponseData: response.data)
//                let json = try? JSONDecoder().decode(BtcBalanceModel.self, from: response.data)
//                if json?.errcode != 0 {
//                    print(json?.msg ?? "get balance error")
//                    return
//                }
//                self?.updateLocalAddressAndBalance(key: key, balance: (json?.data.balance) ?? "0", address: address)
//                self?.tableView.reloadData()
//            case let .failure(error):
//                print("error = \(error)")
//                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
//            }
//        }
//    }
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
                group.leave()
            case let .failure(error):
                print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
                group.leave()
            }
        }
    }
    
    private func updateLocalAddressAndBalance(key:String, balance:String, address:String) {
        self.balanceArr[key] = ["balance":balance, "address":address]
    }
    
    @IBAction func createTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CreateWallet_ManageWalletsPage)
        let cwVc:CreateWalletDetailViewController = CreateWalletDetailViewController()
        cwVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cwVc, animated: true)
    }
    @IBAction func importTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ImportWallet_ManageWalletsPage)
        let iwVc:ImportWalletViewController = ImportWalletViewController()
        iwVc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(iwVc, animated: true)
    }
    
    @IBAction func watchTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_WatchWallet_ManageWalletsPage)
        let wwVc:WatchWalletViewController = WatchWalletViewController()
        self.navigationController?.pushViewController(wwVc, animated: true)
    }
    //    private func refresh(refreshControl:WalletRefreshControl) {
//        self.setContent()
//    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.walletArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var height: CGFloat = 0.3 * (self.view.frame.size.height - 44 - 50)
//        if height > 170 {
//            height = 170
//        }
        return 164
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ManageWalletCell = self.tableView.dequeueReusableCell(withIdentifier: "manageWalletCell", for: indexPath) as! ManageWalletCell
        if self.walletArr.count > indexPath.row {
            let model:SwiftWalletModel = self.walletArr[indexPath.row]
            cell.configureContent(model: model)
            
//            if model.extendedPrivateKey != nil {
//                let balanceAndAddress = self.balanceArr[model.extendedPrivateKey!]
//                if (balanceAndAddress != nil) {
//                    cell.configureAmount(amount: balanceAndAddress!["balance"] ?? "--")
//                }
//            } else {
//                cell.configureAmount(amount: "--")
//            }
            
			cell.clickBackUpClosure = {[weak self] in
				let backUp = BackUpWalletViewController()
				backUp.walletModel = model
				self?.navigationController?.pushViewController(backUp, animated: true)
			}
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let walletVC = WalletDetailViewController()
        let model = self.walletArr[indexPath.row]
        
        let cell:ManageWalletCell = tableView.cellForRow(at: indexPath) as! ManageWalletCell
        walletVC.walletModel = model
//        if model.extendedPrivateKey != nil {
//            let balanceAndAddress = self.balanceArr[model.extendedPrivateKey!] ?? [:]
//            walletVC.balance = balanceAndAddress["balance"] ?? "--"
//        } else {
//            walletVC.balance = "--"
//        }
//        walletVC.address = balanceAndAddress["address"] ?? ""
        walletVC.backImg = cell.backImgView.image
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_ManageWallets_page)
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("deinit")
    }
    
}
