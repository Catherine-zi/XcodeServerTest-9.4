//
//  MeViewController.swift
//  SwiftWallet
//
//  Created by Jack on 13/03/2018.
//  Copyright © 2018 DotC United Group. All rights reserved.
//

import UIKit
import UserNotifications

private let topViewH:CGFloat = 218

@objc public class MeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
	
	
	private lazy var mainTab:UITableView = {
		let tab:UITableView = UITableView()//.init(frame: CGRect.init(x: 15, y: (topViewH - 24), width: self.view.bounds.width - 30, height: self.view.bounds.height - (topViewH + SafeAreaTopHeight - 24)), style: .plain)
        let tabHeight = self.navigationController?.tabBarController?.tabBar.bounds.height ?? 60
        tab.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: tabHeight, right: 0)
		tab.delegate = self
		tab.dataSource = self
		tab.register(MeTableViewCell.classForCoder(), forCellReuseIdentifier: "MeTableViewCell")
		tab.register(MeMutiTableViewCell.classForCoder(), forCellReuseIdentifier: "MeMutiTableViewCell")
		tab.backgroundColor = view.backgroundColor
		tab.separatorStyle = .none
		tab.showsVerticalScrollIndicator = false
		tab.showsHorizontalScrollIndicator = false
		tab.layer.cornerRadius = 4
		tab.layer.masksToBounds = true
		tab.bounces = false
        let footer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 15))
        footer.backgroundColor = tab.backgroundColor
        tab.tableFooterView = footer
		return tab
	}()

	private let dataArr = [

		[
            ["title":SWLocalizedString(key: "my_account"),"imageName":"me_MyAccount"]
        ],
        [
            ["title":SWLocalizedString(key: "currency_unit"),"imageName":"iconcu"]
        ],
		[
            ["title":SWLocalizedString(key: "notifications"),"imageName":"me_iconnotifications"],
            ["title":SWLocalizedString(key: "feedback"),"imageName":"me_iconfeedback"]
        ],
        
		[
            ["title":SWLocalizedString(key: "settings"),"imageName":"me_iconsettings"],
//            ["title":SWLocalizedString(key: "Alert History"),"imageName":"me_iconsettings"]

        ]
    ]
	
	private var models: [[MeCellModel]] {
		
		var results: [[MeCellModel]] = []
		for arr in dataArr {
			
			var subRes: [MeCellModel] = []
			for nameDic in arr {
				
				var model:MeCellModel = MeCellModel()
				
				model.imageName = nameDic["imageName"]
				model.titleName = nameDic["title"]
				model.notificationIsHidden = true
				model.sepIsHidden = true
				model.accountText = ""
				subRes.append(model)
			}
			
			results.append(subRes)
		}
		
		return results
	}
	override public func viewDidLoad() {
        super.viewDidLoad()
        
		self.navigationController?.navigationBar.isHidden = true
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Me_TabBar)//打点

		NotificationCenter.default.addObserver(self, selector: #selector(userLogout), name: SWNotificationName.userLogout.notificationName, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(userLogout), name: SWNotificationName.userLogin.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNotificationBadge), name: SWNotificationName.changeNotification.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshViewWithAppLanguage), name: NSNotification.Name(rawValue: RefreshAppLanguageNotificationName), object: nil)

        setUpViews()

    }
    
    @objc func refreshViewWithAppLanguage() {
//        for subView in self.view.subviews {
//            subView.removeFromSuperview()
//        }
//        setUpViews()
        let tabbar: SWTabBarController = self.navigationController?.tabBarController as! SWTabBarController
        tabbar.resetTabbarController()
    }
	@objc func userLogout() {
		self.tableReload()
	}
    @objc func setNotificationBadge() {
        self.tableReload()
    }
    @objc func tableReload() {
        self.mainTab.reloadData()
    }
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	private func setUpViews() {
		
		self.view.backgroundColor = UIColor.init(hexColor: "F2F2F2")
		
		if #available(iOS 11.0, *) {
			mainTab.contentInsetAdjustmentBehavior = .never
		} else {
			self.automaticallyAdjustsScrollViewInsets = false
		}
		
		//add nav
//		createNavView()
		
		//add topView
		createTopView()
		
		//add tabView
		view.addSubview(self.mainTab)
        self.mainTab.snp.makeConstraints { (make) in
            make.top.equalTo(topViewH - 24)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
        }
	}
	
	private func createNavView() {
		
		let navView = UIView()
		navView.backgroundColor = UIColor.white
		
		let lb = UILabel()
		lb.text = "PROFILE"
		lb.font = UIFont.boldSystemFont(ofSize: 15)
		lb.textColor = UIColor.init(hexColor: "333333")
		lb.textAlignment = .center
		navView.addSubview(lb)
		lb.snp.makeConstraints { (make) in
			make.leading.trailing.equalTo(navView)
			make.bottom.equalTo(navView)
			make.height.equalTo(44)
		}
		self.view.addSubview(navView)
		navView.snp.makeConstraints { (make) in
			make.leading.trailing.equalTo(self.view)
			make.top.equalTo(self.view)
			make.height.equalTo(SafeAreaTopHeight)
		}
		
	}
	private func createTopView() {
		
		let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SWScreen_width, height: topViewH))
		topView.backgroundColor = UIColor.white
		self.view.addSubview(topView)
		let topImageV:UIImageView = UIImageView(image: #imageLiteral(resourceName: "me_topBackground"))
		topImageV.frame = topView.frame
		topImageV.isUserInteractionEnabled = true
		topView.addSubview(topImageV)
		
		if let path = Bundle.main.path(forResource: "config", ofType: "plist") {
			if let dict = NSDictionary(contentsOfFile: path),let str:String = dict["isHiddenAssets"] as? String {
				if str == "yes" {//不隐藏
					return
				}
			}
		}
		
		let manageWBtn = UIButton()
		manageWBtn.setBackgroundImage(UIImage.init(named: "me_manageWallets"), for: .normal)
		manageWBtn.addTarget(self, action: #selector(clickManageWallet), for: .touchUpInside)
		
		let transactionRBtn = UIButton()
		transactionRBtn.setBackgroundImage(UIImage(named:"me_transactionrecords"), for: .normal)
		transactionRBtn.addTarget(self, action: #selector(clickTransactionR), for: .touchUpInside)
		
		let manageTitle = UILabel()
		manageTitle.text = SWLocalizedString(key: "manage_wallets")
		manageTitle.textColor = UIColor.white
		manageTitle.font = UIFont.boldSystemFont(ofSize: 15)
		
		let transactionTitle = UILabel()
		transactionTitle.text = SWLocalizedString(key: "transaction_records")
		transactionTitle.textColor = UIColor.white
		transactionTitle.font = UIFont.boldSystemFont(ofSize: 15)
		
		topView.addSubview(manageWBtn)
		topView.addSubview(transactionRBtn)
		topView.addSubview(manageTitle)
		topView.addSubview(transactionTitle)
		
		manageWBtn.snp.makeConstraints { (make) in
			make.top.equalTo(topView).offset(64)
			make.left.equalTo(topView).offset(64)
			make.width.height.equalTo(60)
		}
		transactionRBtn.snp.makeConstraints { (make) in
			make.right.equalTo(topView).offset(-64)
			make.top.equalTo(topView).offset(64)
			make.width.height.equalTo(60)
		}
		manageTitle.snp.makeConstraints { (make) in
			make.centerX.equalTo(manageWBtn)
			make.top.equalTo(manageWBtn.snp.bottom).offset(15)
		}
		transactionTitle.snp.makeConstraints { (make) in
			make.centerX.equalTo(transactionRBtn)
			make.top.equalTo(transactionRBtn.snp.bottom).offset(15)
		}
	}
	
	@objc private func clickManageWallet() {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_ManageWallets)
		let manageWalletVC = ManageWalletViewController()
        manageWalletVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(manageWalletVC, animated: true)
	}
	@objc private func clickTransactionR(){
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_TransactionRecords)
		let transactionVC = TransactionListViewController()
        transactionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(transactionVC, animated: true)
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 3 {
//            return 2
//        }
		return 1
	}
	public func numberOfSections(in tableView: UITableView) -> Int {
		return dataArr.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		if indexPath.section == 2 {
			let cell:MeMutiTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeMutiTableViewCell") as! MeMutiTableViewCell
			cell.dataArr = models[indexPath.section]
			return cell
		}
		let cell:MeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeTableViewCell") as! MeTableViewCell
		
		var dataA = models[indexPath.section][indexPath.row]
		dataA.sepIsHidden = true
		dataA.notificationIsHidden = true
		
		if indexPath.section == 0 {
			
			if TelegramUserInfo.shareInstance.phoneNumber != nil {
				dataA.accountText = TelegramUserInfo.shareInstance.phoneNumber! as String
			}else{
				dataA.accountText = ""
			}
		}else{
			dataA.accountText = ""
		}
		
		cell.model = dataA
		
		cell.selectionStyle = .none
		return cell
	}
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 3 {
//            return 48
//        }
		return CGFloat(models[indexPath.section].count * 48)
	}
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let Header = UIView(frame: CGRect(x: 0, y: 0, width: SWScreen_width, height: 15))
        Header.backgroundColor = view.backgroundColor
        return Header
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 15
    }
//    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footer = UIView(frame: CGRect(x: 0, y: 0, width: SWScreen_width, height: 15))
//
//    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 15
//    }
//    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 0.0
//    }
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		var vc:UIViewController?
		if indexPath.section == 0 {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_MyAccount)
			if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
				vc = MyProfileViewController()//MyAccountViewController()
			}else {
				let isAgreeServicePolicy = UserDefaults.standard.bool(forKey: "isAgreeServicePolicy")
				if isAgreeServicePolicy == true {
					vc = TelegramConfirmViewController()
				}else {
					var urlStr:String
					if TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hans.rawValue).rawValue == 0 || TelegramUserInfo.shareInstance.currentLanguage.caseInsensitiveCompare(CurrentLanguage.Chinese_Hant.rawValue).rawValue == 0 {
						urlStr = ServiceAgreementCN
					} else {
						urlStr = ServiceAgreementEN
					}
					let webViewVC:ServicePolicyViewController = ServicePolicyViewController()
					webViewVC.urlStr = urlStr
					webViewVC.hidesBottomBarWhenPushed = true
					self.navigationController?.pushViewController(webViewVC, animated: true)
					return;
				}

			}

		}
        if indexPath.section == 1 {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_CuurrencyUnit_Settings)
            vc = ChangeCurrencyViewController()
            self.definesPresentationContext = true
            vc!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.navigationController?.tabBarController?.present(vc!, animated: false, completion: nil)
            return
        }

        if indexPath.section == 3 {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Settings)
            vc = SettingViewController()
        }

		vc!.hidesBottomBarWhenPushed = true
		self.navigationController?.pushViewController(vc!, animated: true)
	}
}
