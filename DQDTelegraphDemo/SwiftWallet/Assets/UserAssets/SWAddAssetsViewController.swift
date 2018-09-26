//
//  SWAddAssetsViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/20.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
import SnapKit

class SWAddAssetsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

	var model:SwiftWalletModel? {
		didSet {
			
			if model?.coinType == CoinType.ETH {
				loadGetTokens()
			}
		}
	}
	var assetsType:[AssetsTokensModel] = []
    var displayArray:[AssetsTokensModel] = []
    var tokenArray:[AssetsTokensModel] = []
    var titleLbl:UILabel = UILabel()
    var searchBtn:UIButton = UIButton()
    var searchView:UIView = UIView()
	var mainTab:UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_AddAssets_Page)

		self.setUpViews()
        self.configureContent(dataArray: self.tokenArray)
    }

	private func loadGetTokens(){
		
		AssetsAPIProvider.request(AssetsAPI.getTokens) { [weak self](result) in
			
			switch result {
			case let .success(response):
                let decryptedData = Data.init(decryptionResponseData: response.data)

				let json = try? JSONDecoder().decode(AssetsGetTokensModel.self, from: decryptedData)
				if json?.code != 0 {
					print("error getTokens")
					return
				}
				self?.configureContent(dataArray: json?.data)
			case let .failure(error):
				print("error = \(error)")
                self?.noticeOnlyText(SWLocalizedString(key: "network_error"))
			}

		}
	}
    
    private func configureContent(dataArray: [AssetsTokensModel]?) {
        DispatchQueue.main.async {
            
            guard var ethTokens = dataArray else{
                return
            }
            
            //reload data
            guard let assetsTypes = self.model?.assetsType else {
                return
            }
            for assetsType:AssetsTokensModel in assetsTypes {
                
                for (index,value) in ethTokens.enumerated() {
                    if value.contractName == assetsType.contractName {
                        
                        var newToken = value
                        newToken.isSelected = true
                        
                        ethTokens[index] = newToken
                    }
                }
                
            }
            self.assetsType = ethTokens
            self.displayArray = self.assetsType
            self.mainTab?.reloadData()
        }
    }
	
	//store assetsType
	deinit {
		
		guard let model = model else {
			return
		}
		guard let originAssetsType = model.assetsType else {
			return
		}
		if assetsType.count == 0 {
			return
		}

		//get selectType
		let walletArr = SwiftWalletManager.shared.walletArr
		var forStoreAssetsType = getSelectedAssetsType()
		
		//forStore add eth
		for originType in originAssetsType {
			
			if originType.symbol == "ETH" {
				forStoreAssetsType.insert(originType, at: 0)
				break
			}
		}
		
		
		for (_,value) in walletArr.enumerated() {
			if value.extendedPublicKey == model.extendedPublicKey {
				
				value.assetsType = forStoreAssetsType
				break
			}
		}
        
        self.uploadEvent()
		
		let success = SwiftWalletManager.shared.storeWalletArr()
		
		if success {
			NotificationCenter.post(customeNotification: SWNotificationName.reloadAssetsType)
		}
		print("success = \(success)")
	}
	
	private func getSelectedAssetsType() -> [AssetsTokensModel] {
		var arr:[AssetsTokensModel] = []
		for model:AssetsTokensModel in assetsType {
			if model.isSelected == true {
				arr.append(model)
			}
		}
		return arr
	}
    
    private func uploadEvent() {
        if !SPUserEventsManager.shared.checkNeedUpdateToday(SWUEC_Currency_Status_AddAssets_Page) {
            return
        }
        
        var eventStr = ""
        for model:AssetsTokensModel in assetsType {
            if model.symbol != nil {
                eventStr += (model.symbol! + ":" + (model.isSelected == true ? "1" : "0") + ";")
            }
        }
        SPUserEventsManager.shared.trackEventAction(SWUEC_Currency_Status_AddAssets_Page, eventPrame: eventStr)
    }
	
	private func setUpViews(){
		
		self.view.backgroundColor = UIColor.white
		
		self.addNavView()
		let tab:UITableView = UITableView.init(frame: CGRect.init(x: 0, y: SWStatusBarH+SWNavBarHeight, width: SWScreen_width, height: SWScreen_height - (SWStatusBarH+SWNavBarHeight)), style: UITableViewStyle.plain)
		tab.delegate = self
		tab.dataSource = self
		tab.register(UINib.init(nibName: "SWAddAssetsCell", bundle: nil), forCellReuseIdentifier: "SWAddAssetsCell")
		
		tab.separatorColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
		tab.separatorInset = UIEdgeInsets.zero
		tab.backgroundColor = UIColor.white
		
		self.view.addSubview(tab)
		tab.tableFooterView = UIView()
		mainTab = tab
	}
	
	private func addNavView(){
		let navView:UIView = UIView.init(frame: CGRect.init(x: 0, y: SWStatusBarH, width: SWScreen_width, height: SWNavBarHeight))
		self.view.addSubview(navView)
		
		let backBtn:UIButton = UIButton.init()
		backBtn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
		backBtn.setImage(UIImage.init(named: "addAssets_back"), for: UIControlState.normal)
//        let searchBtn:UIButton = UIButton.init()
		searchBtn.addTarget(self, action: #selector(searchShow), for: UIControlEvents.touchUpInside)
		searchBtn.setImage(UIImage.init(named: "addAssets_search"), for: UIControlState.normal)
//        searchBtn.isHidden = true
		
//        let title:UILabel = UILabel.init()
		titleLbl.text = SWLocalizedString(key: "wallet_add_assets")
        
        self.searchView.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        self.searchView.isHidden = true
        self.searchView.layer.cornerRadius = 3
        self.searchView.clipsToBounds = true
        let searchField = UITextField()
        searchField.font = UIFont.systemFont(ofSize: 12)
        searchField.placeholder = SWLocalizedString(key: "search_token")
        searchField.borderStyle = .none
        searchField.delegate = self
        let separator = UIView()
        separator.backgroundColor = UIColor.init(white: 0.7, alpha: 1)
        let closeSearchBtn = UIButton()
        closeSearchBtn.setImage(#imageLiteral(resourceName: "iconsearchdelet"), for: .normal)
        closeSearchBtn.addTarget(self, action: #selector(searchHide), for: .touchUpInside)
        self.searchView.addSubview(searchField)
        self.searchView.addSubview(separator)
        self.searchView.addSubview(closeSearchBtn)
		
		navView.addSubview(backBtn)
		navView.addSubview(searchBtn)
		navView.addSubview(titleLbl)
        navView.addSubview(self.searchView)
		
		backBtn.snp.makeConstraints { (make) in
			make.left.equalTo(navView).offset(16)
			make.centerY.equalTo(navView)
			make.height.width.equalTo(44)
		}
		searchBtn.snp.makeConstraints { (make) in
			make.right.equalTo(navView).offset(-16)
			make.centerY.equalTo(navView)
			make.height.width.equalTo(44)
		}
		titleLbl.snp.makeConstraints { (make) in
			make.centerY.centerX.equalTo(navView)
		}
        self.searchView.snp.makeConstraints { (make) in
            make.left.equalTo(backBtn.snp.right).offset(10)
            make.centerY.equalTo(backBtn)
            make.height.equalTo(32)
            make.right.equalTo(-15)
        }
        searchField.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.bottom.equalTo(0)
        }
        separator.snp.makeConstraints { (make) in
            make.left.equalTo(searchField.snp.right)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalTo(1)
        }
        closeSearchBtn.snp.makeConstraints { (make) in
            make.left.equalTo(separator.snp.right)
            make.right.top.bottom.equalTo(0)
            make.width.equalTo(48)
        }
	}
    
    @objc func searchShow() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Seach_AddAssets_Page)
        self.titleLbl.isHidden = true
        self.searchBtn.isHidden = true
        self.searchView.isHidden = false
        self.searchToken(string: "")
    }
    
    @objc func searchHide() {
        self.titleLbl.isHidden = false
        self.searchBtn.isHidden = false
        self.searchView.isHidden = true
        self.displayArray = self.assetsType
        self.mainTab?.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str:String = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        self.searchToken(string: str)
        
        return true
    }
    
    private func searchToken(string: String) {
        self.displayArray.removeAll()
        let lowerCaseStr = string.lowercased()
        for asset in self.assetsType {
            if asset.symbol?.lowercased().contains(lowerCaseStr) == true {
                self.displayArray.append(asset)
                continue
            }
            if asset.contractName?.lowercased().contains(lowerCaseStr) == true {
                self.displayArray.append(asset)
                continue
            }
            if asset.contractAddress?.lowercased().contains(lowerCaseStr) == true {
                self.displayArray.append(asset)
                continue
            }
        }
        self.mainTab?.reloadData()
    }
	
	@objc func back(){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_AddAssets_Page)
		self.navigationController?.popViewController(animated: true)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return displayArray.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:SWAddAssetsCell = tableView.dequeueReusableCell(withIdentifier: "SWAddAssetsCell") as! SWAddAssetsCell
		cell.contentView.backgroundColor = UIColor.init(red: 242, green: 242, blue: 242)
		cell.selectionStyle = .none
		if indexPath.row < displayArray.count {
			cell.model = displayArray[indexPath.row]
			
			cell.changeSelectedBlock = {[weak self](model:AssetsTokensModel) in
				
//                self?.displayArray[indexPath.row] = model
                self?.replaceAsset(asset: model)
			}
		}
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
    
    private func replaceAsset(asset: AssetsTokensModel) {
        for (index, model) in assetsType.enumerated() {
            if model.contractAddress == asset.contractAddress {
                assetsType[index] = asset
                break
            }
        }
    }

}

