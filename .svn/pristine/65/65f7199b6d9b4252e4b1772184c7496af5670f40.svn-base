//
//  ChangeLanguageViewController.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/6/28.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

struct LanguageModel:Codable {
    
    var language:String
    var languageCode:String
    var state:Bool
}
class ChangeLanguageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!

    var languageModels:[LanguageModel] = []
    let languageCodes = [CurrentLanguage.English,CurrentLanguage.Chinese_Hans,CurrentLanguage.Chinese_Hant,CurrentLanguage.Japanese,CurrentLanguage.Korean,CurrentLanguage.Russian]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        self.view.addSubview(blurView)
        self.view.bringSubview(toFront: bgView)
    }
    
    func loadUI() {
        self.titleLabel.text = SWLocalizedString(key: "language")
        self.saveBtn.setTitle(SWLocalizedString(key: "setting_dialog_save"), for: .normal)
        
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView.init()
        tableView.register(UINib.init(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguageTableViewCell")
        let languages = ["English","简体中文","繁體中文","日本語","중국어 간체","Pусский"]

        let currentLanguageCode:String = UserDefaults.standard.object(forKey: BitUpAppLanguageKey) as! String
        
        for (index, language) in languages.enumerated() {
            let code: CurrentLanguage = languageCodes[index]
            let state = (code.rawValue == currentLanguageCode) ? true : false
            let model:LanguageModel = LanguageModel.init(language: language, languageCode: code.rawValue, state: state)
            languageModels.append(model)
        }
         DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func closeBtnClick(_ sender: UIButton) {
//        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
   
    @IBAction func saveBtnClick(_ sender: UIButton) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Save_Language)

        for (index, item) in languageModels.enumerated() {
            if item.state == false { continue }
            TelegramUserInfo.shareInstance.currentLanguage = self.languageCodes[index].rawValue
            UserDefaults.standard.set(item.languageCode, forKey: BitUpAppLanguageKey)
            
            //修改语言时同步修改涨跌色值
            if TelegramUserInfo.shareInstance.currentLanguage.compare("ja").rawValue == 0 ||
                TelegramUserInfo.shareInstance.currentLanguage.compare("zh-Hans").rawValue == 0 ||
                TelegramUserInfo.shareInstance.currentLanguage.compare("zh-Hant").rawValue == 0 {
                UserDefaults.standard.set(false, forKey: GainsColorUISwitchStateKey)
                TelegramUserInfo.shareInstance.settingColorFlag = false
            } else {
                UserDefaults.standard.set(true, forKey: GainsColorUISwitchStateKey)
                TelegramUserInfo.shareInstance.settingColorFlag = true
            }
            UserDefaults.standard.synchronize()

        }
        self.dismiss(animated: false) {
			SWTabBarController.resetTelegramLanguage()
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: RefreshAppLanguageNotificationName)))
        }
        
       
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.languageModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LanguageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        let model = languageModels[indexPath.row]
        cell.titleBtn.setTitle(model.language, for: .normal)
        cell.stateBtn.isSelected = model.state
        cell.titleBtn.isSelected = model.state
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if model.state == true {
            cell.titleBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.titleBtn.setTitleColor( .white, for: .selected)
        } else {
            cell.titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.titleBtn.setTitleColor(UIColor.init(hexColor: "789BF9"), for: .normal)
        }
        if indexPath.row == (languageModels.count - 1) {
            cell.separator.isHidden = true
        } else {
            cell.separator.isHidden = false
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = languageModels[indexPath.row]
        model.state = true
//        languageModels.insert(model, at: indexPath.row)
        var newModels:[LanguageModel] = []
        
        for (index,item) in languageModels.enumerated() {
            let state : Bool = indexPath.row==index ? true : false
            let newModel:LanguageModel = LanguageModel.init(language: item.language, languageCode: item.languageCode, state: state)
            newModels.append(newModel)
        }
        languageModels.removeAll()
        languageModels = newModels
        tableView.reloadData()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: false, completion: nil)
    }
}










