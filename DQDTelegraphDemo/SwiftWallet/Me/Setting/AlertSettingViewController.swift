//
//  AlertSettingViewController.swift
//  DQDTelegraphDemo
//
//  Created by AVAZU on 2018/8/30.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

struct AlertModel: Codable {
    var alertDesc: String
    var alertType: String//AlertType.rawValue
    var settingAlertType: String//SettingAlertType.rawValue
    var state: Bool
}

enum AlertType:String {
    case SoundAndVibration 
    case Vibration
    case Sound
}
enum SettingAlertType:String {
    case AlertSetting
    case ChangeColor
}

let SettingAlertSettingTypeKey = "SettingAlertSettingTypeKey"

class AlertSettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var saveActionBlock : ((String)->())?
    
    @IBOutlet weak var bgView: SWCornerRadiusView!
    @IBOutlet weak var bgViewConstraint_height: NSLayoutConstraint!

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var tempAlertType:String?
    private var tempGainsColor: String?

    var modelArr:[AlertModel]?

    var settingTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        self.view.addSubview(blurView)
        self.view.bringSubview(toFront: bgView)
    }
    
    func loadUI()  {
        titleLabel.text = settingTitle
        saveBtn.setTitle(SWLocalizedString(key: "setting_dialog_save"), for: .normal)
        tableView.rowHeight = 71
        tableView.tableFooterView = UIView.init()
        tableView.register(UINib.init(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguageTableViewCell")
   
        if (modelArr?.count)! < 3 {
            bgViewConstraint_height.constant -= 71
        }

    }
    @IBAction func closeBtnClick(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func saveBtnClick(_ sender: UIButton) {
        if settingTitle == SWLocalizedString(key: "setting_change_color") {
            if tempGainsColor != nil {
                let state : Bool = tempGainsColor == SWLocalizedString(key: "gurd") ? true :false
                UserDefaults.standard.set(state, forKey: GainsColorUISwitchStateKey)
                TelegramUserInfo.shareInstance.settingColorFlag = state
                NotificationCenter.post(customeNotification: SWNotificationName.gainsColor)
                if saveActionBlock != nil {
                    saveActionBlock!(tempGainsColor!)
                }
            }
        } else {
            if tempAlertType != nil {
                UserDefaults.standard.set(tempAlertType, forKey: SettingAlertSettingTypeKey)
               var alertSettingString = SWLocalizedString(key: "s_and_v")
                switch tempAlertType {
                case AlertType.SoundAndVibration.rawValue:
//                    alertSettingString = SWLocalizedString(key: "s_and_v")
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
                if saveActionBlock != nil {
                    saveActionBlock!(alertSettingString)
                }
            }
        }
        self.dismiss(animated: false, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LanguageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        let model = modelArr![indexPath.row]
        cell.titleBtn.setTitle(model.alertDesc, for: .normal)
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
        if indexPath.row == ((modelArr?.count)! - 1) {
            cell.separator.isHidden = true
        } else {
            cell.separator.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model = modelArr![indexPath.row]
        model.state = true
        if model.settingAlertType == SettingAlertType.AlertSetting.rawValue {
            tempAlertType = model.alertType
        } else {
            tempGainsColor = model.alertDesc
        }
        var newModels:[AlertModel] = []
        
        for (index,item) in (modelArr?.enumerated())! {
            let state : Bool = indexPath.row==index ? true : false
            let newModel:AlertModel = AlertModel.init(alertDesc: item.alertDesc, alertType: item.alertType, settingAlertType: item.settingAlertType, state: state)
            newModels.append(newModel)
        }
        modelArr?.removeAll()
        modelArr = newModels
        tableView.reloadData()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: false, completion: nil)
    }
}
