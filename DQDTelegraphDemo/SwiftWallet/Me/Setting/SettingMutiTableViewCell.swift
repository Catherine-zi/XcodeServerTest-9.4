//
//  SettingMutiTableViewCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/5/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class SettingMutiTableViewCell: UITableViewCell,UITableViewDataSource,UITableViewDelegate {
	
	var dataArr:[SettingModel]? = [] {
		didSet {
			tab.reloadData()
			
			backView.layer.cornerRadius = 5
			backView.layer.masksToBounds = true
		}
	}
	
	private let backView = UIView()
	private let tab = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setUpViews()
	}
	
	private func setUpViews() {
		
		backView.backgroundColor = UIColor.white
		
		self.contentView.addSubview(backView)
		backView.snp.makeConstraints { (make) in
			make.edges.equalTo(self.contentView)
		}
		
		tab.delegate = self
		tab.dataSource = self
		//		tab.bounces = false
		tab.separatorStyle = .none
		tab.register(SettingTableViewCell.classForCoder(), forCellReuseIdentifier: "SettingTableViewCell")
		tab.isScrollEnabled = false
		backView.addSubview(tab)
		tab.snp.makeConstraints { (make) in
			make.edges.equalTo(backView)
		}
	}
	
	override func willMove(toSuperview newSuperview: UIView?) {
		
		self.backgroundColor = self.superview?.backgroundColor
		self.contentView.backgroundColor = self.backgroundColor
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (dataArr?.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell:SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell") as! SettingTableViewCell
		
		var dataA = dataArr![indexPath.row]
		dataA.sepIsHidden = indexPath.row == (dataArr?.count)! - 1 ? true : false
		cell.model = dataA
		
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 48
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.0
	}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataA = dataArr![indexPath.row]
        switch dataA.type {
        case .AlertSetting?:
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_AlertSetting_Settings)

            var str = UserDefaults.standard.object(forKey: SettingAlertSettingTypeKey)
            if str == nil {
                str = AlertType.SoundAndVibration.rawValue
            }
            let model1 = AlertModel.init(alertDesc: SWLocalizedString(key: "s_and_v"),
                                         alertType: AlertType.SoundAndVibration.rawValue,
                                         settingAlertType: SettingAlertType.AlertSetting.rawValue,
                                         state: (str as! String == AlertType.SoundAndVibration.rawValue))
            let model2 = AlertModel.init(alertDesc: SWLocalizedString(key: "vibration"),
                                         alertType: AlertType.Vibration.rawValue,
                                         settingAlertType: SettingAlertType.AlertSetting.rawValue,
                                         state: (str as! String == AlertType.Vibration.rawValue))
            let model3 = AlertModel.init(alertDesc: SWLocalizedString(key: "sound"),
                                         alertType: AlertType.Sound.rawValue,
                                         settingAlertType: SettingAlertType.AlertSetting.rawValue,
                                         state: (str as! String == AlertType.Sound.rawValue))
            let models:[AlertModel] = [model1,model2,model3]
            let vc:AlertSettingViewController = AlertSettingViewController()
            vc.modelArr = models
            vc.settingTitle = SWLocalizedString(key: "setting_alert_setting")
            vc.saveActionBlock = { [weak self] (alertSettingStr) in
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_Save_AlertSetting)
                let newModel = SettingModel.init(name: dataA.name, desc: alertSettingStr, type: dataA.type, sepIsHidden: dataA.sepIsHidden)
                self?.dataArr?.remove(at: indexPath.row)
                self?.dataArr?.insert(newModel, at: indexPath.row)
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.viewController().present(vc, animated: false, completion: nil)
            break
            
        case SettingCellType.ChangeColor?:
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_ChangeColor_Settings)
            let isOpenGains = UserDefaults.standard.bool(forKey: GainsColorUISwitchStateKey)
            let model1 = AlertModel.init(alertDesc: SWLocalizedString(key: "gurd"),
                                         alertType: "",
                                         settingAlertType: SettingAlertType.ChangeColor.rawValue,
                                         state: isOpenGains)
            let model2 = AlertModel.init(alertDesc: SWLocalizedString(key: "rugd"),
                                         alertType: "",
                                         settingAlertType: SettingAlertType.ChangeColor.rawValue,
                                         state: !isOpenGains)
            let models:[AlertModel] = [model1,model2]
            let vc:AlertSettingViewController = AlertSettingViewController()
            vc.modelArr = models
            vc.settingTitle = SWLocalizedString(key: "setting_change_color")
            vc.saveActionBlock = { [weak self] (gains) in
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Click_Save_ChangeColor)
                let newModel = SettingModel.init(name: dataA.name, desc: gains, type: dataA.type, sepIsHidden: dataA.sepIsHidden)
                self?.dataArr?.remove(at: indexPath.row)
                self?.dataArr?.insert(newModel, at: indexPath.row)
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.viewController().present(vc, animated: false, completion: nil)
            break
            
        case SettingCellType.Language?:
            
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Language_Settings)
            let vc:ChangeLanguageViewController = ChangeLanguageViewController()
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.viewController().present(vc, animated: false, completion: nil)
            break
            
        case SettingCellType.TermsService?:
            
            var urlStr: String
            if TelegramUserInfo.shareInstance.currentLanguage == CurrentLanguage.Chinese_Hans.rawValue || TelegramUserInfo.shareInstance.currentLanguage == CurrentLanguage.Chinese_Hant.rawValue {
                urlStr =  ServiceAgreementCN
            } else {
                urlStr = ServiceAgreementEN
            }
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_TermsofService)
            let webViewVC:WebViewController = WebViewController()
            webViewVC.urlStr = urlStr
            self.viewController().navigationController?.pushViewController(webViewVC, animated: true)
            break
            
        case SettingCellType.PrivacyPolicy?:
            
            var urlStr: String
            if TelegramUserInfo.shareInstance.currentLanguage == CurrentLanguage.Chinese_Hans.rawValue || TelegramUserInfo.shareInstance.currentLanguage == CurrentLanguage.Chinese_Hant.rawValue {
                urlStr = PrivacyAgreementCN
            } else {
                urlStr = PrivacyAgreementEN
            }
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_PricacyPolicy)
            let webViewVC:WebViewController = WebViewController()
            webViewVC.urlStr = urlStr
            self.viewController().navigationController?.pushViewController(webViewVC, animated: true)
            break
        default:
			let vc = TestSettingViewController()
			self.viewController().navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
