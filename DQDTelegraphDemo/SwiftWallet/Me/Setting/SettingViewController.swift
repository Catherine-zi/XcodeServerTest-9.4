//
//  SettingViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/2.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

enum SettingCellType {
    case AlertSetting
    case ChangeColor
    case Language
    case TermsService
    case PrivacyPolicy
}

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var navTitleLabel: UILabel!
    
	@IBOutlet weak var mainTab: UITableView!
	@IBOutlet weak var loginBtn: UIButton!
	
   
	private var models: [[SettingModel]] = []
	
	private let headerHeight:CGFloat = 15.0
    private let language: String = {
        let currentLanguageCode:String = UserDefaults.standard.object(forKey: BitUpAppLanguageKey) as! String
        let languages = ["English","简体中文","繁體中文","日本語","중국어 간체","Pусский"]
        let languageCodes = [CurrentLanguage.English,CurrentLanguage.Chinese_Hans,CurrentLanguage.Chinese_Hant,CurrentLanguage.Japanese,CurrentLanguage.Korean,CurrentLanguage.Russian]
        var languageStr:String = ""
        for (index, code) in languageCodes.enumerated() {
            let code: String = languageCodes[index].rawValue
            if code == currentLanguageCode {
                languageStr = languages[index]
            }
//            if code == TelegramUserInfo.shareInstance.currentLanguage?.rawValue {
//                languageStr = languages[index]
//            }
        }
        return languageStr
    }()
    
    private let alertSettingStr: String = {
        let settingAlertSettingType = UserDefaults.standard.object(forKey: SettingAlertSettingTypeKey)
        var alertSettingString = SWLocalizedString(key: "s_and_v")
        if settingAlertSettingType != nil {
            switch settingAlertSettingType as! AlertType.RawValue {
            case AlertType.SoundAndVibration.rawValue:
                alertSettingString = SWLocalizedString(key: "s_and_v")
                break
            case AlertType.Sound.rawValue:
                alertSettingString = SWLocalizedString(key: "sound")
                break
            case AlertType.Vibration.rawValue:
                alertSettingString = SWLocalizedString(key: "vibration")
                break
            default:
                break
            }
        }
        return alertSettingString
    }()
    
    private let gainsStr: String = {
        let isOpenGains = UserDefaults.standard.bool(forKey: GainsColorUISwitchStateKey)
        //        var gains: String?
        //        if isOpenGains == nil {
        //            gains = SWLocalizedString(key: "rugd")
        //        } else {
        let gains: String = isOpenGains == true ? SWLocalizedString(key: "gurd") : SWLocalizedString(key: "rugd")
        //        }
        return gains
    }()
    private var dataArr:[Array<Dictionary<String,Any>>] = []
    
	override func viewDidLoad() {
        super.viewDidLoad()
        loadModels()
		setUpViews()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCurrency), name: SWNotificationName.currencySettingChange.notificationName, object: nil)
    }
    
    private func loadModels() {
        
        

       
        
        dataArr = [
            [
                ["title":SWLocalizedString(key: "setting_alert_setting"), "desc":alertSettingStr, "type":SettingCellType.AlertSetting]
            ],
            [
                ["title":SWLocalizedString(key: "language"), "desc":language, "type":SettingCellType.Language],
                ["title":SWLocalizedString(key: "terms_of_service"), "desc":"", "type":SettingCellType.TermsService],
                ["title":SWLocalizedString(key: "privacy_policy"), "desc":"", "type":SettingCellType.PrivacyPolicy]
            ]
        ]
        
        let langStr = UserDefaults.standard.object(forKey: BitUpAppLanguageKey) as? String
        if langStr == CurrentLanguage.Chinese_Hans.rawValue || langStr == CurrentLanguage.Chinese_Hant.rawValue || langStr == CurrentLanguage.Japanese.rawValue {
            dataArr[0].append(["title":SWLocalizedString(key: "setting_change_color"), "desc":gainsStr, "type":SettingCellType.ChangeColor])
        }
        
        var results: [[SettingModel]] = []
        for arr in dataArr {
            
            var subRes: [SettingModel] = []
            for nameDic in arr {
                
                var model:SettingModel = SettingModel()
                
                model.name = nameDic["title"] as? String
                model.desc = nameDic["desc"] as? String
                model.type = nameDic["type"] as? SettingCellType

                model.sepIsHidden = true
                
                subRes.append(model)
            }
            
            results.append(subRes)
        }
        
        models = results
    }
    
    @objc private func refreshCurrency() {
        
        var currencyModel = SettingModel()
        currencyModel.desc = SwiftExchanger.shared.currency.rawValue
        currencyModel.name = SWLocalizedString(key: "currency_unit")
        currencyModel.sepIsHidden = true
        models[0][1] = currencyModel
        mainTab.reloadData()
    }
    
    @objc private func showTestSetting() {
        
        var currencyModel = SettingModel()
        currencyModel.desc = "for test"
        currencyModel.name = "Network Settings"
        currencyModel.sepIsHidden = true
        models[1].append(currencyModel)
        mainTab.reloadData()
    }

	private func setUpViews() {
        
        self.navTitleLabel.isUserInteractionEnabled = true
        let recongnizer = UITapGestureRecognizer.init(target: self, action: #selector(showTestSetting))
        recongnizer.numberOfTapsRequired = 10
        self.navTitleLabel.addGestureRecognizer(recongnizer)
		
		mainTab.delegate = self
		mainTab.dataSource = self
		mainTab.showsHorizontalScrollIndicator = false
		mainTab.showsVerticalScrollIndicator = false
		mainTab.separatorColor = mainTab.backgroundColor
		mainTab.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		mainTab.register(SettingTableViewCell.classForCoder(), forCellReuseIdentifier: "SettingTableViewCell")
		mainTab.register(SettingMutiTableViewCell.classForCoder(), forCellReuseIdentifier: "SettingMutiTableViewCell")
		mainTab.register(SettingMutiTableViewCell.classForCoder(), forCellReuseIdentifier: "SettingMutiTableViewCell")
        mainTab.register(GainsSwitchTableViewCell.classForCoder(), forCellReuseIdentifier: "GainsSwitchTableViewCell")

        self.navTitleLabel.text = SWLocalizedString(key: "settings")
		loginBtn.setTitle(TelegramUserInfo.shareInstance.telegramLoginState == "yes" ? SWLocalizedString(key: "log_out_bitPub") : SWLocalizedString(key: "log_in_bitPub"), for: UIControlState.normal)
		loginBtn.backgroundColor = TelegramUserInfo.shareInstance.telegramLoginState == "yes" ? UIColor.init(hexColor: "F96C6C") : UIColor.init(hexColor: "1E59F5")
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    

	@IBAction func clickLoginBtn(_ sender: UIButton) {
		
		if TelegramUserInfo.shareInstance.telegramLoginState == "yes" {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_LogOutTelegram)

			let verifyView = Bundle.main.loadNibNamed("LogoutConfirmView", owner: nil, options: nil)?.first as! LogoutConfirmView
			verifyView.frame = CGRect.init(x: 30, y: 250, width: SWScreen_width - 60, height: 158)
			let visualView = VisualEffectView.visualEffectView(frame:view.bounds)
			visualView.contentView.addSubview(verifyView)
			view.addSubview(visualView)
			
			verifyView.cancelBlock = {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Cancel_LogOutTelegram_Popup)
				visualView.removeFromSuperview()
			}
			verifyView.confirmBlock = {[weak self] in
				//log out
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Confirm_LogOutTelegram_Popup)

				self?.loginBtn.setTitle(SWLocalizedString(key: "log_in_bitPub") , for: UIControlState.normal)
				self?.loginBtn.backgroundColor = UIColor.init(hexColor: "1E59F5")
				visualView.removeFromSuperview()
				
				SWTabBarController.logout()
				NotificationCenter.post(customeNotification: SWNotificationName.userLogout)
			}
		}else {
	
//			let chatInTabBarCount:Int = 1
//			self.tabBarController?.selectedIndex = chatInTabBarCount
//
//			guard let tabVc:UITabBarController = self.tabBarController else{
//				return
//			}
//			if tabVc.viewControllers?.count == 4 {
//				let vc:UIViewController = tabVc.viewControllers![1]
//				if vc.isKind(of: UINavigationController.classForCoder()) {
//					let nav:UINavigationController = vc as! UINavigationController
//					nav.viewControllers = [ChatLoginViewController(),TelegramConfirmViewController()]
//				}
//			}
//
//			self.navigationController?.popViewController(animated: false)
			let isAgreeServicePolicy = UserDefaults.standard.bool(forKey: "isAgreeServicePolicy")
			if isAgreeServicePolicy == true {
				let vc:UIViewController = TelegramConfirmViewController()
				vc.hidesBottomBarWhenPushed = true
				self.navigationController?.pushViewController(vc, animated: true)
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
				
			}
		}
		
	}
	
	@IBAction func clickBackBtn(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_Settings_Page)

		self.navigationController?.popViewController(animated: true)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return models.count
	}
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
//        if indexPath.section == 0  {
//            let cell:SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell") as! SettingTableViewCell
//            cell.model = models[indexPath.section][indexPath.row]
//            
//            cell.selectionStyle = .none
//            return cell
//        }
//        if indexPath.section == 2 {
//            let cell:GainsSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GainsSwitchTableViewCell") as! GainsSwitchTableViewCell
//            cell.selectionStyle = .none
//            cell.titleLbl.text = SWLocalizedString(key: "gains")
//            return cell
//        }
		let cell:SettingMutiTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingMutiTableViewCell") as! SettingMutiTableViewCell
		
		cell.dataArr = models[indexPath.section]
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UIView(frame: CGRect(x: 0, y: 0, width: SWScreen_width, height: headerHeight))
		header.backgroundColor = mainTab.backgroundColor
		return header
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return headerHeight
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(models[indexPath.section].count * 48)
	}
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath.section == 0 {
//            
//        } else if indexPath.section == 1 && indexPath.row == 0 {
//            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Language_Settings)
//            let vc:ChangeLanguageViewController = ChangeLanguageViewController()
//            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//            self.present(vc, animated: false, completion: nil)
//        }
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
